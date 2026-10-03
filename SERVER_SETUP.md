# AI Build by Notascripter — optional relay 0.3.3

The relay is a single JavaScript file using Node.js built-ins. It needs no npm packages. The VM handles HTTPS requests, request limits, presence, owner model access, and shared-chat review; OpenAI runs the model.

**The public client and the VM are separate deployments.** Client 0.3.3's disclosed MetalRod/native-size corrections and context-priority fix work with an installed relay **0.3.2**; no further VM update is required for them. Optional relay **0.3.3** adds stronger material, inventory, geometry, and usable-architecture drafting instructions. It retains the 0.3.2 plan-normalization and 0.3.1 owner allowance behavior. Prompt instructions do not prove successful building or avatar clearance. Client updates do not change the running server.

## Update the existing Ubuntu VM

Use the matching **key-free server-update package**, containing `server.mjs`, `update-server.sh`, and `UPDATE_SERVER.txt`. It does not contain a populated `.env`, OpenAI key, administrator token, or copy of the operator's quota data.

Copy/extract the package on the VM and run from that package directory:

```sh
sudo bash update-server.sh
```

The supplied script requires a system-wide Node.js 22 or newer and targets the existing `/opt/forgeai` installation, Linux account `forgeai`, and service `forgeai.service`. It honors the configured `PORT` (default 3000). It checks the new JavaScript, backs up the installed server and `.env`, stops the service, installs the update, restarts it, and checks the reported relay version and administrator availability. If installation or the health check fails, it attempts to restore the previous server, environment, and token file and restart the previous service.

It preserves the current OpenAI key and persistent quota/review file. The actual `FORGE_STATE_FILE` path from `.env` is resolved relative to `/opt/forgeai` and backed up when present. Rollback keeps accepted quota/grant records instead of resetting usage. This file can now contain shared AI conversation snapshots, so treat its backups as private too. Do not replace the real `.env` with `server.env.example`.

The updater reuses a valid configured administrator token or generates a private one when needed. It writes the active token to `/opt/forgeai/admin-token.txt` with root-only permissions. The owner can read it locally on the VM and enter it once in the existing in-game **Admin** page after opening the workspace. The normal startup flow is retained. Never publish the token or include it in a client script, screenshot, or chat export.

Check both the local service and the existing HTTPS path:

```sh
curl --fail http://127.0.0.1:3000/health
curl --fail https://r.eggsmp.gg/forgeai/health
```

Expect `"ok":true`, `"relayVersion":"0.3.3"`, and `"adminEnabled":true` after this optional update. The health response may retain the internal `ForgeAI` name for compatibility. A healthy response checks the process and version; it does not spend an AI request, prove model access, or validate in-game building.

## New installation or manual deployment

Use a supported Node.js installation providing `fetch`, `AbortSignal.timeout`, and `--env-file`. Check the administrator's installed runtime with `node --version`; official distributions are available from [Node.js](https://nodejs.org/en/download). Keep the service directory outside the web server's static document root.

For a manual development installation, put `server.mjs` and `server.env.example` in a directory owned by the account running the service:

```sh
mkdir -p "$HOME/forgeai"
cd "$HOME/forgeai"
cp server.env.example .env
chmod 600 .env
nano .env
```

Set the private OpenAI project key on the VM. The account must have working GPT-5.5 API access and billing. Do not add the populated file to GitHub or send it to the executor.

The configuration fields are:

| Variable | Meaning |
|---|---|
| `OPENAI_API_KEY` | Private server-side OpenAI project credential. |
| `HOST` | Keep `127.0.0.1` when a local HTTPS proxy or tunnel fronts the service. |
| `PORT` | Node's local listener; default `3000`. The updater reads the configured value for its health check. |
| `FORGE_STATE_FILE` | Persistent quota, player, grant, receipt, and shared AI-review state. Preserve and protect this path and its backups across restarts. Public server-chat buffers are kept separately in memory. |
| `FORGE_DAILY_REQUEST_LIMIT` | Public accepted requests per UTC day, 1–10,000; default 100. Authenticated owner calls bypass this ceiling. This is a request ceiling, not a currency budget. |
| `FORGE_TRUST_LOCAL_PROXY` | `1` only for a trusted local proxy that overwrites `X-Real-IP`. |
| `FORGE_TRUST_CLOUDFLARE_TUNNEL` | `1` only for local `cloudflared` forwarding directly to Node with the verified visitor-IP header. |
| `FORGE_ADMIN_TOKEN` | Random private owner credential, 32–256 characters without whitespace. Empty disables administrator endpoints. |

Do not enable both proxy trust modes. A fresh owner token can be generated on the VM with Node's cryptographic random generator and stored only in the private configuration. The supplied existing-installation updater performs that step when needed.

Start the service from its directory:

```sh
node --env-file=.env server.mjs
```

Run exactly one service process per state file. An invalid existing state file stops startup rather than silently granting everyone a fresh allowance. Keep private backups of the state file and `.env`.

## Existing HTTPS proxy

Keep Node bound to loopback. Forward the chosen HTTPS address to `http://127.0.0.1:3000`, preserving the existing domain and certificate setup.

For a direct local Nginx proxy, put this location inside the existing HTTPS `server` block and use `FORGE_TRUST_LOCAL_PROXY=1`:

```nginx
location /forgeai/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_http_version 1.1;
    proxy_read_timeout 330s;
    proxy_send_timeout 330s;
    client_max_body_size 256k;
    proxy_buffering off;
}
```

The proxy must overwrite client-supplied visitor-IP headers. If it is behind another proxy, configure the trusted real-IP chain there. Otherwise everyone may appear to share one address and one network allowance. Validate/reload Nginx using the VM administrator's existing process. Do not expose `.env`, state files, token files, backups, or the service directory through static hosting.

Owner inference allows **300 seconds upstream** and **315 seconds in the client**; ordinary inference remains at 120/135 seconds. The 330-second Nginx values leave room for the owner path. The server-update script does not change your proxy configuration. Review the timeout on every active proxy/tunnel hop and in the executor; a shorter timeout can interrupt the client even while an accepted AI request continues. An uncertain result must not be automatically resubmitted; an ordinary accepted request can still count against quota.

For an existing local Cloudflare Tunnel connected directly to Node, retain `FORGE_TRUST_LOCAL_PROXY=0` and `FORGE_TRUST_CLOUDFLARE_TUNNEL=1`. This mode requires a valid Cloudflare visitor-IP header from a loopback peer. Do not change a working proxy topology just to install the relay update.

## Public client configuration

The new public repository serves the loader, manifest, configuration, and distribution files from its root:

```text
https://github.com/datadaniklan/AI-Build-Notascripter
```

Root `config.json` should contain only public service configuration:

```json
{
  "apiBase": "https://r.eggsmp.gg/forgeai",
  "status": "online"
}
```

Use the actual HTTPS base address without a trailing slash. The `status` string is informational, not proof of relay-version compatibility. Never put an API key or owner token in this file. The loader fetches `manifest.json` and its versioned `dist/forgeai_<build>.lua`; those internal names and the `forgeai` workspace directory are retained to preserve compatibility.

The example systemd unit remains named `forgeai.service` and uses `/opt/forgeai` with the `forgeai` account. Adapt the absolute Node path to the installed runtime. Renaming the product does not require renaming the working service, state file, account, or executor data directory.

## Allowance, ownership, and retained data

The free allowance is 10 accepted upstream requests per 48-hour window, guarded by both the supplied Roblox ID and public network. Two upstream requests can run concurrently, with one in flight per reported player. Accepted request receipts prevent automatic duplicate submission/charging. Upstream failures and timeouts can still consume an accepted request; retries are not silently sent.

Administrator requests require the private token regardless of which Roblox ID a caller supplies. Owner model selection/inference and remote chat-review reads additionally require owner player ID `8093680942`. Grant amounts are 1–100 requests per action, with at most 1,000 outstanding bonus requests per reported user. Grant receipts are retained for duplicate protection. Bonus requests still count toward public daily capacity. On relay 0.3.1 or newer, a valid administrator token plus owner ID `8093680942` enables unlimited prompts: owner calls bypass the free player/network allowance, bonus spending, and public daily request ceiling. They retain durable request receipts, model validation, output/time limits, two concurrent requests globally, and one in flight per player. A claimed owner ID without the token receives ordinary quota. OpenAI usage is still billed to the operator.

Client-reported identity is not verified Roblox sign-in. The owner panel's account check is a UI convenience; the server token is the authorization boundary. Presence records include public user ID/name, place ID, job ID, and last-seen time, plus a hashed network identifier for quota calculations. “Online” means a presence report within 150 seconds. Old presence records are removed after 30 days when the registry is updated; the registry is capped at 5,000 records and the admin response returns at most 1,000.

The relay state includes quota buckets, request receipts, presence, grants, grant receipts, and **AI conversation snapshots submitted for review**. Ordinary inference does not itself write a transcript to that file, and raw IPs are not stored there. For an AI request, the client sends bounded recent conversation, enabled memory, current build context, and any relevant read-only inspection report through the relay to OpenAI with `store: false`. Infrastructure access logs remain a separate administrator responsibility.

New/default client settings enable both AI-prompt sharing and public server-chat sharing. The startup screen discloses these choices before **Open AI Build**; users can turn either off before opening, and saved Off choices remain Off. Automatic collection and sharing are gated until Open. The presence/quota calls are separate from these sharing controls. Manual **Share for review** is an explicit submission even when automatic AI sharing is off.

Shared AI reviews contain up to 20 user/assistant messages, at most 1,000 UTF-16 units each, and a title up to 120 units. There is one current review per reported user, at most 200 reviews and 4 MiB overall. Updates are limited to once per five minutes. Reviews persist in `FORGE_STATE_FILE` until replacement or successful withdrawal; private backups may retain prior copies. Turning AI sharing off requests deletion, and opening with that setting already off also requests withdrawal of prior shared data.

Public server-chat sharing observes only new successful `RBXGeneral` messages delivered to the sharing client; it excludes whispers/direct messages, team/system channels, and prior history. The client refreshes a rolling snapshot about every 15 seconds, keeping at most 100 messages from the last ten minutes, with text capped at 500 UTF-8 bytes. The relay enforces its own field limits, permits refreshes no more often than every five seconds, and holds at most 200 buffers / 4 MiB **in memory only**. Each buffer expires ten minutes after its last refresh, is removed on successful withdrawal, and disappears on relay restart. Closing the client stops collection but does not by itself erase the last uploaded buffer.

The owner can read available shared data for a selected service user without joining that server. These snapshots are client-reported, not an authenticated transcript or arbitrary remote-server access. Disabling sharing stops its local collection and requests withdrawal; a pending upload is followed by another withdrawal when it returns. Network failure can prevent delivery of a withdrawal. The public profile lookup checks only a fixed Roblox account endpoint and confirms account metadata, not ownership of a claimed service identity.

The owner Models page lists account-accessible models from the relay's supported Responses/structured-output families. Its catalog is cached for five minutes. The chosen model and its supported reasoning effort are validated; an unsupported or unavailable choice fails without an automatic model switch. Ordinary users remain on GPT-5.5. Model preferences persist in settings. Client 0.3.1 and newer separately remember the authenticated owner token in `forgeai/admin_8093680942.key`, a plain local credential file; **Forget** removes it. It is not included in chat/settings or public bundles.

## Acceptance after updating

1. If applying the optional VM update, confirm local and public health report relay 0.3.3, and confirm whether administrator access is enabled.
2. Send one ordinary greeting. It should produce a normal answer without inventing a build plan, leave Build disabled, and clear stale progress/errors.
3. Prepare a small supported build on a clear portion of the own plot. Review the preview, run it once, and inspect the actual placed result.
4. Check fixed-size parts keep their native dimensions. An exactly native-size request may be omitted with a note; a mismatched Lamp size still fails. Review a decorative MetalRod-to-MetalBlock adjustment as a rectangular approximation before building; wired, mounted, or functional components must not be substituted.
5. Check save/load and re-execution retain local chats/plans without resubmitting an attempted action.
6. Before Open AI Build, verify the sharing disclosure and both switches. Test Off choices remain Off and no chat collection begins before Open. Then verify an enabled review upload and its withdrawal, including a pending-request opt-out.
7. As the owner, authenticate Admin, confirm unlimited status, remembered-credential reconnect and Forget, recent presence, public profile details, model/effort choices, and a remote review from a sharing client. An unavailable/stale review must stay explicit. Make a small explicit request grant and verify it applies once. Test joining only when leaving the current session is intended.
8. Exercise an owner request through the real HTTPS path and confirm no proxy cuts it off at the old 150-second setting. A health check cannot verify this timeout path.
9. For a vehicle, verify wheel orientation, body clearance, mount relationships, complete native key bindings, steering, and actual controlled movement. Placement alone is insufficient.

The initial public client's 12-part car placement did not verify driving. The source and mock tests for the new release do not replace these live acceptance checks.
