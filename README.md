# AI Build by Notascripter

A chat workspace with native building tools for your own **Build A Boat For Treasure** plot. Ask an ordinary question, design a build, review its plan, and run the requested stage from the same window.

**Client preview 0.3.1; relay 0.3.1.** This update fixes stale loading, adds a visible version/build badge, improves storage recovery and relay-status refresh, and remembers the authenticated owner's admin credential in a separate local file. **The matching VM update is required for unlimited authenticated owner prompts**, including when the relay already runs 0.3.0. See [UPDATE_SERVER.txt](UPDATE_SERVER.txt). Updating a public loader does not update the VM.

The initial live client placed a 12-part car, but its wheel placement and bindings needed correction. That establishes basic placement only. The new vehicle behavior, inspector, and administrator flow still need acceptance checks in the actual executor/game/server combination. [FEATURES.md](FEATURES.md) records the implemented capabilities and their verification limits.

## Start

Run this line in an executor with HTTP requests, `loadstring`, and workspace file access:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/loader.lua?ai_build_refresh="..game:GetService("HttpService"):GenerateGUID(false)))()
```

The free plan uses **GPT-5.5**. Review the two sharing switches on the startup screen before choosing **Open AI Build**. New/default settings share recent AI prompts and public server chat with the operator; either can be switched **Off before opening**, and saved Off choices remain Off. Chat collection and sharing start only after Open. Premium subscriptions remain unavailable. The authenticated owner has a separate Models page.

- For ordinary conversation, type normally. Chat can work without an available build plot, including in another Roblox place, when the relay is compatible.
- For building, join Build A Boat For Treasure, load your own unlaunched plot, keep Share Blocks off, and describe what you want.
- Read the proposed stage and its preview, then select **Build current plan**. The preview is an approximation; it does not establish successful placement or working physics.
- Use **Stop** to stop further work. A request already sent to the game can still finish, and completed parts remain.

The project is published at [AI-Build-Notascripter](https://github.com/datadaniklan/AI-Build-Notascripter). Use this canonical command to avoid a cached first-stage launcher. Supported legacy loader entrypoints redirect to it, and `forgeai/start.lua` is refreshed to fetch the canonical launcher on each run. The loader requests fresh metadata, checks the release version, size, build header, SHA-256, and compilation, then opens the validated client. The window's version/build badge identifies the loaded release. Running an old `client_*.lua` cache directly still runs that old client. Keep the existing `forgeai` folder; upgrading does not delete saved chats or old caches.

## What is included

- Chats, saved build plans, editable memory, persistent settings, and a Free/GPT-5.5 onboarding flow.
- A dark workspace with the Notascripter byline, window scaling, minimize/restore, and a draggable compact logo.
- An isolated, rotating 3D approximation of the staged plan. It uses simple parts in a UI viewport and never creates preview parts on the live plot.
- An owner-only Activity panel with entries for actual reported requests, responses, stages, errors, and stops. These are application events, not the model's private reasoning.
- Stage progress and a measured estimate once enough progress samples exist.
- Placement, supported resizing, painting, moving, rotating, properties, Sign text, circuit bindings, full native vehicle bindings, mounts, Rope endpoints, bounded Button tests, copying, mirroring, selected deletion/unbinding, camera framing, and own-plot character approach.
- Relevant read-only game inspection that supplies bounded client-visible script excerpts and native mechanical template observations to the AI. It uses a first-party inspector; the upstream Dex application is not bundled or opened.
- Owner controls for operator-visible service users, request grants, and an explicit join-server action, protected by a private server-issued administrator token.
- An owner Models page populated from the real API account's compatible text-model catalog, including GPT-6 Astra when available.
- Remote owner review of shared AI prompts and public server chat, without joining the reported server, plus public Roblox profile details. Sharing remains visible and user-controlled.

Plans are limited to **100 new blocks, 100 edits, and 200 combined connections**. Copy/mirror plans select at most 100 source blocks. Tests, copying, deletion, unbinding, camera views, and character approaches run as separate bounded jobs. Larger projects need multiple stages. The model returns declarative plans; model-generated Lua is not executed.

Normal tool limits still apply. Lamps, Gates, Delays, Buttons, Signs, and other non-scalable types keep their native dimensions. Invalid resizing is rejected during preparation before the plan starts. Piston length and speed are settings; they do not by themselves prove the piston moved. Vehicle placement and bindings must be followed by real motion checks before a vehicle can be described as drivable.

## Saving and loading

Chats, settings, memory, and blueprints remain in the executor's **`forgeai`** workspace folder. This internal name is retained for compatibility with the earlier ForgeAI preview. Each Roblox user has a separate two-file journal with readback checks and recovery from the last valid copy. The loader's cache and `forgeai/start.lua` also remain in that folder.

Unreadable or unsupported saved files are preserved. If safe recovery is unavailable, the client reports the problem and disables saving instead of replacing the files with empty state. A failed launcher download, integrity check, compilation, or verified cache write leaves the current interface running; it does not silently execute an older cache.

**Save build stores a plan, not a native Roblox save slot or the entire plot.** Loading a saved build opens its plan for review. It runs only when you select the build action, or when you have explicitly enabled automatic building for a newly generated valid plan. Existing targets are checked again against their saved type, position, rotation, and size; missing or ambiguous targets require a fresh plan. Use the game's own Save menu to retain the complete in-game build.

Settings include autosave, remembered chats, AI memory, automatic building, reduced motion, UI scale, reasoning effort, response length, and the two sharing controls. Window size and position persist independently of chat autosave. Automatic building starts off. New/default sharing settings start on, with both switches disclosed before Open; saved Off settings stay off. Turning off remembered chats excludes them from subsequent disk saves; a previous recovery copy can still contain earlier chats until both journal slots have been replaced. Activity history and the administrator token are not saved as chat memory.

## Requests and service data

The free allowance is **10 accepted AI requests per 48-hour window**, starting with the first accepted request. An operator can grant extra requests. The server counts requests, so editing local files does not reset the allowance. An accepted upstream request still counts if it later fails. Chat switching, saving/loading local plans, inspecting the local preview, and checking quota do not use an AI request.

This preview receives a client-reported Roblox ID and also applies a shared-network guard. It does **not** authenticate Roblox account ownership. Users on the same public IP can share the free network allowance. The relay also applies a public daily request ceiling and a concurrency limit; extra grants do not remove those server limits. On relay 0.3.1, the authenticated owner has unlimited prompts: a valid administrator token plus owner ID 8093680942 bypasses the free player/network allowance, bonus spending, and public daily ceiling. A claimed owner ID alone receives the ordinary allowance. Request receipts, model validation, output/time limits, two concurrent requests globally, and one in flight per player still apply. Unlimited prompts do not mean unlimited provider capacity or free OpenAI usage.

While the client is open, it reports service presence about once per minute: public Roblox ID/username, place ID, current server job ID, and last-seen time. These client-reported values are visible to the authorized operator. “Online” means recently reported, not an independently verified Roblox session. The operator's join action uses the reported server location and remains subject to Roblox access and server availability.

The client also refreshes quota and relay compatibility during these checks, so grants and a completed server update can appear without restarting the interface. A health/version response alone does not prove every owner or game operation works.

For an AI request, recent conversation, enabled memory, bounded plot/inventory information, and any relevant inspection report pass through the relay to OpenAI. Script inspection is limited to currently client-visible code and can be unavailable. Recognized credential patterns are redacted, but this is not a complete secret-detection guarantee. Native executor decompilation is labeled reconstructed, and its internal network behavior is unknown; the inspector does not choose or download an external decompiler.

The relay persists hashed quota identifiers, request receipts, client-reported player/server metadata, bonus balances, grant receipts, and AI review snapshots submitted through the sharing feature. Ordinary inference does not itself save a server-side chat transcript. Old presence entries are removed after 30 days when presence records are updated. OpenAI requests use `store: false`; infrastructure providers can have separate operational logs.

## Shared chat review

**AI prompts:** when sharing is enabled, the client sends a current snapshot of up to 20 user/assistant messages, capped at 1000 UTF-16 units per message, with a title capped at 120 units. Updates occur at most once per five minutes. **Share for review** explicitly submits a snapshot even when automatic sharing is off and follows the same update limit. The relay keeps one current snapshot per reported user, up to 200 snapshots and 4 MiB total. A snapshot remains until replacement or successful withdrawal. Turning the sharing switch off requests withdrawal of the current snapshot; private relay backups can still contain older copies.

**Public server chat:** after Open, enabled sharing observes new messages in the current server's public **RBXGeneral** channel. It excludes whispers/direct messages, team and system channels, and prior chat history. The client refreshes a rolling snapshot about every 15 seconds, keeping up to 100 messages from the last ten minutes with usernames, reported user IDs, timestamps, and text capped at 500 UTF-8 bytes; the relay additionally enforces a 500-character text limit. The relay keeps one current server buffer per reported player, at most 200 buffers and 4 MiB total, and permits refreshes no more often than once per five seconds. A buffer expires ten minutes after its last refresh, is removed on successful withdrawal, and disappears on relay restart. Rolling public-chat contents are held in memory rather than the durable quota/review file. Closing the client stops collection; an existing buffer remains until withdrawal or expiry.

Opening with either sharing setting already Off requests withdrawal of its previously shared data. Turning a switch Off also stops its local collection/update queue. If an older upload is still in flight, the client requests withdrawal again after it returns. A network failure can prevent the relay from receiving a withdrawal, so Off does not guarantee immediate remote deletion while disconnected.

The authorized owner selects a player from the service-user list and can view the available shared data remotely. The list itself contains sharing timestamps and metadata, not message contents. Locations, sender identities, and submitted messages are **client-reported and unverified**. Sharing, withdrawal, viewing, profile lookup, grants, joins, and catalog reads do not consume AI requests.

AI Build does not send recipient pop-ups when the owner views data, grants requests, or requests a join. The sharing switches and disclosure remain visible. Normal Roblox presence and join behavior still apply.

## Server update and owner controls

The public client and the server-update package contain **no OpenAI key or administrator credential**. The OpenAI key belongs in the VM's private `.env` file. The update script preserves the existing key and quota/review file, creates an administrator token when one is absent, and checks relay version 0.3.1 after restart.

The startup screen keeps its normal Free/GPT-5.5 flow. The built-in owner account can open the existing **Admin** page after opening the workspace and enter the private token once. After successful server authentication, client 0.3.1 saves it separately in **`forgeai/admin_8093680942.key`** and reconnects automatically on later launches. **Forget** removes the saved credential and disconnects; closing the window does not forget it. Credential persistence does not add the token to chat history, settings, shared-review payloads, or public release bundles. This is a **plain local credential file, not encryption**; other software with access to the executor workspace can read it, and workspace backups can contain it. Authorization is still checked by the server; the visible owner tab and local file alone grant no authority. Grants and joins require explicit button actions.

Owner model selection and remote chat reads require the valid token **and owner player ID 8093680942**. The authenticated model catalog intersects account access with documented Responses/structured-output compatibility. The account check found **21 compatible current aliases**, plus eligible dated snapshots, across GPT-6, GPT-5, GPT-4.1, and GPT-4o families. This includes **GPT-6 Astra**, whose supported efforts are low, medium, high, xhigh, and max. **Ultra is not supported.** Unknown, specialized, audio, image, and other unverified variants are excluded; the picker does not promise every API model. Availability is refreshed through a bounded catalog lookup cached for five minutes, and unsupported or unavailable choices fail without switching models. See the [official GPT-6 Astra model documentation](https://developers.openai.com/api/docs/models/gpt-6-astra).

Ordinary users keep GPT-5.5 with low, medium, or high reasoning. Authenticated owner calls on relay 0.3.1 use the unlimited allowance described above; ordinary callers retain the free quotas. GPT-4.1/4o entries offer none and omit reasoning/verbosity parameters. Owner inference has a 300-second upstream timeout and a 315-second client timeout; ordinary calls remain at 120/135 seconds. The executor or HTTPS proxy may time out earlier. The direct Nginx example uses 330 seconds, and the updater does not change an existing proxy configuration. An uncertain accepted request is not automatically retried; ordinary accepted requests can still count against quota.

See [SERVER_SETUP.md](SERVER_SETUP.md) for deployment details, [UPDATE_SERVER.txt](UPDATE_SERVER.txt) for the existing VM update, and [FEATURES.md](FEATURES.md) for the complete feature/verification checklist.

The distributed client is obfuscated. Obfuscation is reversible and is not encryption or a place to hide credentials. The software is an independent preview, not an official Roblox, Build A Boat For Treasure, OpenAI, or Dex product. See [NOTICE.txt](NOTICE.txt).
