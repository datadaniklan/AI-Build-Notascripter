# AI Build by Notascripter

A chat workspace with native building tools for your own **Build A Boat For Treasure** plot. Ask an ordinary question, design a build, review its plan, and run the requested stage from the same window.

**Preview release.** The current client requires **relay 0.2.0** for general conversation, the expanded native operations, presence, and administrator controls. The existing server at `https://r.eggsmp.gg/forgeai` must receive the matching server update; updating this public loader does not update the Ubuntu VM. See [UPDATE_SERVER.txt](UPDATE_SERVER.txt) for the operator handoff.

The initial live client placed a 12-part car, but its wheel placement and bindings needed correction. That establishes basic placement only. The new vehicle behavior, inspector, and administrator flow still need acceptance checks in the actual executor/game/server combination. [FEATURES.md](FEATURES.md) records the implemented capabilities and their verification limits.

## Start

Run this line in an executor with HTTP requests, `loadstring`, and workspace file access:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/loader.lua"))()
```

Choose **Free**, choose **GPT-5.5**, then continue. Premium and additional models are unavailable in this preview.

- For ordinary conversation, type normally. Chat can work without an available build plot, including in another Roblox place, when the relay is compatible.
- For building, join Build A Boat For Treasure, load your own unlaunched plot, keep Share Blocks off, and describe what you want.
- Read the proposed stage and its preview, then select **Build current plan**. The preview is an approximation; it does not establish successful placement or working physics.
- Use **Stop** to stop further work. A request already sent to the game can still finish, and completed parts remain.

The project is published at [AI-Build-Notascripter](https://github.com/datadaniklan/AI-Build-Notascripter). Existing users should switch to this loader URL. Keep the existing `forgeai` workspace folder to retain saved data.

## What is included

- Chats, saved build plans, editable memory, persistent settings, and a Free/GPT-5.5 onboarding flow.
- A dark workspace with the Notascripter byline, window scaling, minimize/restore, and a draggable compact logo.
- An isolated, rotating 3D approximation of the staged plan. It uses simple parts in a UI viewport and never creates preview parts on the live plot.
- Activity entries for actual reported requests, responses, stages, errors, and stops. These are application events, not the model's private reasoning.
- Stage progress and a measured estimate once enough progress samples exist.
- Placement, supported resizing, painting, moving, rotating, properties, Sign text, circuit bindings, full native vehicle bindings, mounts, Rope endpoints, bounded Button tests, copying, mirroring, selected deletion/unbinding, camera framing, and own-plot character approach.
- Relevant read-only game inspection that supplies bounded client-visible script excerpts and native mechanical template observations to the AI. It uses a first-party inspector; the upstream Dex application is not bundled or opened.
- Owner controls for operator-visible service users, request grants, and an explicit join-server action, protected by a private server-issued administrator token.

Plans are limited to **100 new blocks, 100 edits, and 200 combined connections**. Copy/mirror plans select at most 100 source blocks. Tests, copying, deletion, unbinding, camera views, and character approaches run as separate bounded jobs. Larger projects need multiple stages. The model returns declarative plans; model-generated Lua is not executed.

Normal tool limits still apply. Lamps, Gates, Delays, Buttons, Signs, and other non-scalable types keep their native dimensions. Invalid resizing is rejected during preparation before the plan starts. Piston length and speed are settings; they do not by themselves prove the piston moved. Vehicle placement and bindings must be followed by real motion checks before a vehicle can be described as drivable.

## Saving and loading

Chats, settings, memory, and blueprints remain in the executor's **`forgeai`** workspace folder. This internal name is retained for compatibility with the earlier ForgeAI preview. Each Roblox user has a separate two-file journal with readback checks and recovery from the last valid copy. The loader's cache and `forgeai/start.lua` also remain in that folder.

**Save build stores a plan, not a native Roblox save slot or the entire plot.** Loading a saved build opens its plan for review. It runs only when you select the build action, or when you have explicitly enabled automatic building for a newly generated valid plan. Existing targets are checked again against their saved type, position, rotation, and size; missing or ambiguous targets require a fresh plan. Use the game's own Save menu to retain the complete in-game build.

Settings include autosave, remembered chats, AI memory, automatic building, reduced motion, UI scale, reasoning effort, and response length limit. Automatic building starts off. Turning off remembered chats excludes them from subsequent disk saves; a previous recovery copy can still contain earlier chats until both journal slots have been replaced. Activity history and the administrator token are not saved as chat memory.

## Requests and service data

The free allowance is **10 accepted AI requests per 48-hour window**, starting with the first accepted request. An operator can grant extra requests. The server counts requests, so editing local files does not reset the allowance. An accepted upstream request still counts if it later fails. Chat switching, saving/loading local plans, inspecting the local preview, and checking quota do not use an AI request.

This preview receives a client-reported Roblox ID and also applies a shared-network guard. It does **not** authenticate Roblox account ownership. Users on the same public IP can share the free network allowance. The relay also applies an operator-wide daily request ceiling and a concurrency limit; extra grants do not remove those server limits.

While the client is open, it reports service presence about once per minute: public Roblox ID/username, place ID, current server job ID, and last-seen time. These client-reported values are visible to the authorized operator. “Online” means recently reported, not an independently verified Roblox session. The operator's join action uses the reported server location and remains subject to Roblox access and server availability.

For an AI request, recent conversation, enabled memory, bounded plot/inventory information, and any relevant inspection report pass through the relay to OpenAI. Script inspection is limited to currently client-visible code and can be unavailable. Recognized credential patterns are redacted, but this is not a complete secret-detection guarantee. Native executor decompilation is labeled reconstructed, and its internal network behavior is unknown; the inspector does not choose or download an external decompiler.

The relay does not write chat contents to its quota file. It persists hashed quota identifiers, request receipts, client-reported public player/server metadata, bonus balances, and grant receipts. Old presence entries are removed after 30 days when presence records are updated. OpenAI requests use `store: false`; infrastructure providers can have separate operational logs.

## Server update and owner controls

The public client and the server-update package contain **no OpenAI key or administrator credential**. The OpenAI key belongs in the VM's private `.env` file. The update script preserves the existing key and quota file, creates an administrator token when one is absent, and checks relay version 0.2.0 after restart.

The built-in owner account can open **Admin** and enter the private token. Authorization is checked by the server; the visible owner tab alone grants no authority. The token stays in memory during the client session and is cleared on disconnect/close. Granting requests and joining a selected reported server require explicit button actions.

See [SERVER_SETUP.md](SERVER_SETUP.md) for deployment details, [UPDATE_SERVER.txt](UPDATE_SERVER.txt) for the existing VM update, and [FEATURES.md](FEATURES.md) for the complete feature/verification checklist.

The distributed client is obfuscated. Obfuscation is reversible and is not encryption or a place to hide credentials. The software is an independent preview, not an official Roblox, Build A Boat For Treasure, OpenAI, or Dex product. See [NOTICE.txt](NOTICE.txt).
