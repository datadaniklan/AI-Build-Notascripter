# AI Build by Notascripter — relay 0.2.0

The relay is a single JavaScript file using Node.js built-ins. It needs no npm packages. The VM handles HTTPS requests, request limits, presence, and owner controls; OpenAI runs the model.

**The public client and the VM are separate deployments.** Client updates do not change the running server. The expanded client needs relay **0.2.0** for general chat, native vehicle/test/copy plans, presence, and administrator endpoints. The existing service must be updated before those features can be accepted as working.

## Update the existing Ubuntu VM

Use the matching **key-free server-update package**, containing `server.mjs`, `update-server.sh`, and `UPDATE_SERVER.txt`. It does not contain a populated `.env`, OpenAI key, administrator token, or copy of the operator's quota data.

Copy/extract the package on the VM and run from that package directory:

```sh
sudo bash update-server.sh
```

The supplied script requires a system-wide Node.js 22 or newer and targets the existing `/opt/forgeai` installation, Linux account `forgeai`, and service `forgeai.service`. It honors the configured `PORT` (default 3000). It checks the new JavaScript, backs up the installed server and `.env`, stops the service, installs the update, restarts it, and checks the reported relay version and administrator availability. If installation or the health check fails, it attempts to restore the previous server, environment, and token file and restart the previous service.

It preserves the current OpenAI key and request quota file. The actual `FORGE_STATE_FILE` path from `.env` is resolved relative to `/opt/forgeai` and backed up when present. Rollback keeps any accepted quota/grant records instead of resetting usage. Do not replace the real `.env` with `server.env.example`.

The updater reuses a valid configured administrator token or generates a private one when needed. It writes the active token to `/opt/forgeai/admin-token.txt` with root-only permissions. The owner can read it locally on the VM and enter it in the in-game **Admin** page. Never publish the token or include it in a client script, screenshot, or chat export.

Check both the local service and the existing HTTPS path:

```sh
curl --fail http://127.0.0.1:3000/health
curl --fail https://r.eggsmp.gg/forgeai/health
```

Expect `"ok":true`, `"relayVersion":"0.2.0"`, and `"adminEnabled":true` after the provided update. The health response may retain the internal `ForgeAI` name for compatibility. A healthy response checks the process and version; it does not spend an AI request, prove model access, or validate in-game building.

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
| `FORGE_STATE_FILE` | Persistent quota/player/grant state. Preserve this path and its file across restarts. |
| `FORGE_DAILY_REQUEST_LIMIT` | Operator-wide accepted requests per UTC day, 1–10,000; default 100. This is a request ceiling, not a currency budget. |
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
    proxy_read_timeout 150s;
    proxy_send_timeout 150s;
    client_max_body_size 256k;
    proxy_buffering off;
}
```

The proxy must overwrite client-supplied visitor-IP headers. If it is behind another proxy, configure the trusted real-IP chain there. Otherwise everyone may appear to share one address and one network allowance. Validate/reload Nginx using the VM administrator's existing process. Do not expose `.env`, state files, token files, backups, or the service directory through static hosting.

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

Administrator requests require the private token regardless of which Roblox ID a caller supplies. Grant amounts are 1–100 requests per action, with at most 1,000 outstanding bonus requests per reported user. Grant receipts are retained for duplicate protection. Bonus requests still count toward operator-wide daily capacity and concurrency limits.

Client-reported identity is not verified Roblox sign-in. The owner panel's account check is a UI convenience; the server token is the authorization boundary. Presence records include public user ID/name, place ID, job ID, and last-seen time, plus a hashed network identifier for quota calculations. “Online” means a presence report within 150 seconds. Old presence records are removed after 30 days when the registry is updated; the registry is capped at 5,000 records and the admin response returns at most 1,000.

The relay state includes quota buckets, request receipts, presence, grants, and grant receipts. Chat contents and raw IPs are not written to that file. The client sends bounded recent conversation, enabled memory, current build context, and any relevant read-only inspection report to OpenAI with `store: false`. Infrastructure access logs remain a separate administrator responsibility.

## Acceptance after updating

1. Confirm local and public health report relay 0.2.0, and confirm whether administrator access is enabled.
2. Send one ordinary greeting. It should produce a normal answer without inventing a build plan.
3. Prepare a small supported build on a clear portion of the own plot. Review the preview, run it once, and inspect the actual placed result.
4. Check fixed-size parts keep their native dimensions. A generated Lamp resize should fail preparation before game actions.
5. Check save/load and re-execution retain local chats/plans without resubmitting an attempted action.
6. As the owner, authenticate the Admin page, confirm recent presence, make a small explicit request grant, and verify it is applied once. Test joining a reported server only when leaving the current session is intended.
7. For a vehicle, verify wheel orientation, body clearance, mount relationships, complete native key bindings, steering, and actual controlled movement. Placement alone is insufficient.

The initial public client's 12-part car placement did not verify driving. The source and mock tests for the new release do not replace these live acceptance checks.
