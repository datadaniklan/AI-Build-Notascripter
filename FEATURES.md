# AI Build by Notascripter — implementation and verification checklist

This checklist describes the prepared expanded client and **relay 0.3.0**. “Implemented” means there is a bounded source-code path for the feature; “offline covered” means dedicated local tests exercise that path. Neither establishes acceptance by the actual executor, Roblox server, or live physics engine. The final packaged artifact also needs its release checks.

**Deployment boundary:** the public repository is [AI-Build-Notascripter](https://github.com/datadaniklan/AI-Build-Notascripter). The Ubuntu relay must run version 0.3.0 for owner model selection and shared-chat review. Updating to an earlier relay version does not install those features. A GitHub/client release cannot install the server update. See [UPDATE_SERVER.txt](UPDATE_SERVER.txt).

## Chat, appearance, and local workspace

| Request | Implemented behavior | Verification / remaining limit |
|---|---|---|
| AI Build with the Notascripter byline | The window uses the AI Build name and “by Notascripter”; public loader targets the new repository. | UI/source checks; latest bundle needs in-game appearance acceptance. |
| Free and GPT-5.5 onboarding | Free plan and GPT-5.5 are selectable. | UI/API tests. Premium remains unavailable. Authenticated owner model selection is a separate feature below. |
| Ordinary conversation | Relay can return an answer with no plan. Client allows chat without a ready BAFT plot and in other Roblox places. | Client and relay tests. Requires updated relay; old service behavior is not proof this path is deployed. |
| Multiple saved chats | Create, select, and delete chats with per-user local persistence. | Storage and client integration tests. |
| Editable memory | Global preferences and short per-chat project facts are included when memory is enabled. | Tests cover combined request limits and Unicode. Memory is contextual data, not model training. |
| Persistent settings | Autosave, remembered chats, AI memory, automatic building, reduced motion, UI scale, reasoning effort, output limit, and separate sharing preferences. | UI/storage/client tests. Automatic building defaults off. Sharing choices are disclosed before Open AI Build; see the sharing rows below. |
| Minimize and resize | Compact draggable logo, restore behavior, readable scale limits, and viewport bounds. | Native GUI mock checks; latest executor/rendering acceptance remains. |
| 3D preview | At most 100 primitive parts in an isolated UI WorldModel, with approximate placement, size, rotation, color, and an orbiting camera. | Isolation, bounds, rotation, reduced motion, and teardown tests. This is not exact native block geometry or physics simulation. |
| Activity panel | Bounded entries for actual reported request, response, stage, failure, and Stop events. | UI/client checks. It does not display private model reasoning or invent tool activity. |
| Progress and ETA | Adapter progress is reported by phase; ETA appears only after enough measured progress. | Engine tests. It estimates the current stage, not the complete multi-stage project. |
| Stop | Requests cancellation; already dispatched mutations can still complete and are not automatically replayed. | Engine/client cancellation and uncertain-outcome tests. |
| Local save reliability | Two-file journal, readback checks, per-user state, recovery from a valid copy, close-save failure protection. | Storage/client tests. Executor file APIs still require runtime acceptance. |

The preview uses boxes and fallback dimensions where a plan omits native size. It cannot establish wheel facing, tire clearance, mounts, wiring, text filtering, joint behavior, or a working circuit. Read-only template observations and actual game checks are separate evidence.

## Native BAFT operations

| Operation | Public scope | Verification / inherited limit |
|---|---|---|
| Place blocks | Up to 100 available inventory blocks in the own unlaunched plot; plot bounds and native tools checked. | Engine/native adapter tests; limited earlier live placement evidence below. |
| Resize | Eligible ordinary block types through the normal Scaling Tool, 0.05–256 studs per axis. | Engine rejects unsupported types before dispatch. Lamp, Gate, Delay, Button, Sign, and other non-scalable types must omit size. |
| Paint | RGB values 0–255 on requested new/existing parts through the normal tool. | Bounded validation and native readback; activation colors should remain useful. |
| Move / rotate | Up to 100 explicit existing targets through Trowel, using plot-local positions and XYZ degree rotations. | Geometry remapping and adapter identity checks. Compatible edit-only translations use the inherited grouped move path. |
| Basic properties | Anchored, Collision, Cast shadow, and Transparency 0–100. | Native tool validation/readback. |
| Logic modes | Gate And/Or/Xor with independent Not; at most one requested base mode true. | Engine rejects contradictory or incompatible modes. |
| Delay and display | Delay time 0.05–10 seconds; DisplayBlock Additive. | Type/range checks. Additive is display behavior, not a numeric counter. |
| Sign labels | Up to 75 UTF-8 bytes, using the normal game text path. | Text readback and normal filtering remain active; a filtered result is not reported as exact success. |
| Mechanical settings | Observed wheel torque/speed/reverse, servo torque/speed/angle, piston length/speed, and applicable rope/bar properties. | Only declared property/type/range combinations are accepted. Settings are not proof of motion. |
| Single-action wiring | Boolean controller sources to targets with one observed action. | Explicit directed relationship checks. |
| Vehicle / piston wiring | Boolean source with `action: "All"`, or supported seat source with a key for every observed target action. | Full native mapping validation. Individual Boolean Push/Pull selection is unsupported. |
| Connection budget | At most 200 ordinary and vehicle connections combined. | Engine/relay validation. No silent extra binding or invented input names. |
| Mechanical mount | Exact observed part name on an earlier new block or an existing own block. | Forward/self references and same-plan edits to mount targets are rejected; native attachment validation still required. |
| Rope placement | Explicit second endpoint and optional endpoint mounts; endpoints at least two studs apart. | Bounded schema/native endpoint checks. Bar/Spring endpoint construction is not implemented by the inherited adapter. |
| Button press test | Separate plan: 1–16 existing Button presses, 0–32 observed Gates, at most 40 seconds. Empty `observe: []` selects press-only behavior. | Hold 0.05–1 s, gap 0.2–2 s, settle 0.1–2 s; normal click range and admission checks. Press-only success confirms local Button admission, not downstream piston/vehicle motion. |
| Observe without input | Separate Gate readback for 0.1–40 seconds, with no Button presses. | Bounded observation-only mode; does not change the circuit. |
| Clone / mirror | Separate native assembly operation with up to 100 explicit existing sources and available inventory. | Saved geometry remapping, own-plot checks, native verification. The old private adapter's 1,000-source allowance is not exposed publicly. |
| Delete selected blocks | Separate plan with 1–100 explicit existing targets. | No automatic deletion or rollback to conceal a failed build. |
| Unbind selected blocks | Separate plan with 1–100 explicit existing targets. | Native unbinding checks unrelated relationships; no arbitrary wire mutation endpoint. |
| Camera view | Temporary native camera framing; FOV 30–100°, hold 2–30 seconds, with restoration. | Framing supplies no screenshot and proves no visible result by itself. |
| Character approach | Separate own-plot floor position, optionally tied to an existing target's range. | Standing space, ownership, target identity, and context checks; not arbitrary world teleporting. |

Tests, clone/mirror, deletes, unbind, camera view, and character approach are exclusive operations. They cannot be mixed with construction, edits, connections, or another exclusive operation in one plan.

Every saved existing-target reference is remapped from saved type/position/rotation/size against a fresh complete plot snapshot. Missing, moved, duplicated, or ambiguous matches stop the job. Nested plan data is checked before copying; unknown executable fields, cycles, non-finite values, and oversized structures are rejected. One adapter invocation is made, with no automatic mutation retry.

## Integrated read-only inspection

| Request | Implemented behavior | Limit |
|---|---|---|
| Dex-like context without another window | Independent first-party inspector runs for relevant building/mechanics requests. | Upstream Dex/Dex++ is not bundled, installed, or opened. |
| Relevant object/script discovery | Currently replicated storage, replicated-first content, and the local player's script/tool/UI/character roots. | At most 1,800 visited nodes, depth 8, 256 considered children per node, 48 tree entries, and 32 script names. Truncation is reported. |
| Source excerpts | Readable Source is preferred; optional direct executor-native decompilation can supply a reconstruction. | At most 3 excerpts, 8,000 bytes each, 20,000 bytes total. Unsupported/unavailable source stays explicit. |
| No new decompiler service | No fallback URL, external decompiler selection, downloaded provider, or upstream Dex dispatcher. | Executor-native internals can use networking; the report labels that behavior unknown. |
| Bounded native work | Two-second scheduler timeout and cancellation attempt; a timeout disables further native workers in that inspector instance. | Cooperative executor scheduling limits apply; this is not a guarantee that a blocking native implementation can be preempted. |
| Redacted context | Common API-key prefixes, bearer credentials, sensitive quoted assignments, and token/key query parameters are redacted. | Pattern filtering is not complete secret detection. Source remains untrusted reference data. |
| Native wheel/mount geometry | Up to 6 diverse templates, prioritizing explicitly requested, currently placed, and available types. Reports primary-relative full bounds, part orientations, cylinder axle/radial dimensions, attachment axes, hinge states, rigid-joint endpoints, and mesh collision fidelity. | Cosmetic wheel variants do not crowd out other mechanisms. Records remain bounded; missing data is unknown. These are current native-template observations, not proof of placed geometry, attachment, or motion. |
| Exact mount names | Separates unique part names from duplicate names; identifies whether the bounded scan completed. | Incomplete scans do not offer names as exact mount targets. The normal adapter must still validate the actual mount during placement. |
| Piston observations | Reads actual ExtendLength/Speed values, native binding input names, and sliding-constraint properties when those objects exist. | No constraint class or action is invented. Template settings/current position and local Button admission do not establish that a placed piston extended or retracted. |
| Server-code boundary | No hidden services, remote invocation, recovered-code execution, or whole-game export. | The client cannot obtain server-only content that was never replicated; streaming can omit client-visible objects. |
| General-chat privacy boundary | Ordinary unrelated conversation returns no inspection report and performs no inspector service reads. | Topic selection is heuristic; bounded technical context is attached only when selected. |

The 21 dedicated inspector tests cover source preference, hidden/server scope exclusions, stale ancestry, redaction, source budgets, UTF-8, diagnostic handling, native timeout, traversal bounds, and general chat. Mechanical cases cover inventory-aware diverse selection, named native types, nested lookalike exclusion, bounds/axles, false-versus-missing values, duplicate/incomplete mount names, native rigid groups/collision fidelity, and actual-versus-missing piston data. These tests use local adapters; live executor decompilation and physical behavior are still unverified.

## Operator features and service state

| Request | Implemented behavior | Limit / deployment dependency |
|---|---|---|
| Free allowance | 10 accepted AI requests per 48-hour window, with countdown. | Supplied-ID plus shared-network guard; not verified Roblox sign-in. |
| GPT-5.5 | Server-side OpenAI request with bounded settings and structured response. | Requires operator model access/billing and available relay capacity. |
| Owner Admin page | Built-in owner account sees the panel and supplies a private token. | The server token authorizes access; a local ID/tab check is insufficient on its own. |
| User/activity list | Recent client-reported public user, place/server location, request count, last-seen time, and allowance. | Relay 0.3.0 required; “online” means a recent presence report, not independently verified identity. |
| Extra requests | Explicit grant of 1–100 requests, with at most 1,000 bonus requests held. | Server authorization, persisted receipt, and duplicate protection; daily/concurrency ceilings still apply. |
| Join selected server | Explicit join action using the reported place/job ID after local save checks. | Not automatic; Roblox permissions, server lifetime/capacity, and reported-ID accuracy control acceptance. |
| Token handling | Owner token is entered privately, used in memory, and cleared on disconnect/close. | Not bundled, stored in chat, or written to local settings. |
| Key-free public/update packages | Client, public config, and server-update handoff contain no populated secrets. | The existing VM `.env` and quota state must be preserved. |
| Request durability | Persisted accepted-request and grant receipts; quota survives server restart. Attempted build state survives client reload, with an explicit saved-blueprint load required to authorize another copy. | Storage failure blocks plan dispatch; an uncertain accepted request or build is not silently replayed. |
| Owner model selection | Authenticated owner can load the relay's account-accessible, supported text/structured-output model list and select a model. | Relay 0.3.0, owner ID, and private token required. The list is filtered for supported model families and cached for five minutes; it is not a promise that every OpenAI model is usable. |
| Model-specific reasoning | Owner reasoning choices come from the selected supported model's allowed values. Model/effort preferences persist locally; the token does not. | Invalid combinations are rejected. Disconnected owner requests do not silently fall back to another model. Non-owner requests remain on GPT-5.5. |
| Public Roblox profile | Optional fixed-domain public lookup of numeric account ID, username, display name, description, creation date, ban flag, and profile link. | No credentials are sent. Response capped at 128 KiB; fields validated/truncated; ten-second request/scheduler limit; five-minute cache with at most 100 entries. A public account's existence does not authenticate the service user's claimed identity. |
| Share AI conversation | Explicit Share for review sends up to the latest 20 user/assistant messages, each at most 1,000 UTF-16 units. The separate AI-sharing setting permits periodic updates of queued conversations. | On first use the setting starts enabled, with a visible choice before Open AI Build; saved disabled choices stay disabled. No automatic sharing starts before Open AI Build. Updates are limited to once per five minutes. Turning it off requests removal of the shared review. |
| Share received public server chat | Separate setting observes only new successful RBXGeneral messages delivered to that client, then refreshes its bounded rolling snapshot on the relay about every 15 seconds. | Initially enabled with a choice before Open AI Build. A disabled setting starts no collector. At most 100 buffered messages from the last ten minutes, 500 UTF-8 bytes each; no history fetch, whisper, team, direct or system messages. Unavailable General chat stays unavailable. |
| Review selected player's shared chats | Authenticated owner can request the selected service player's shared AI review or reported public server-chat buffer without joining that server. | Requires a sharing client; it cannot remotely inspect arbitrary players or servers. Public-chat buffers are client-reported, expire after ten minutes without an update, and are kept in relay memory only. Missing/stale sharing is reported explicitly. |
| Sharing teardown and failure behavior | Disabling public sharing stops the observer, clears its rolling buffer and requests relay removal; disabling AI sharing requests review removal. Open AI Build also withdraws old data for saved disabled choices. Late in-flight uploads trigger a second removal after they return. | Public-chat snapshots refresh on the next scheduled tick after failure; an AI-review share is not automatically replayed. One timer loop remains active even during an in-flight upload. Closing disposes observers and prevents later collection/upload. A disconnected client cannot guarantee delivery of a removal request. |

Player presence is disclosed in the client and sent about once per minute while open. The relay state retains public player/server metadata, hashed network quota identifiers, request receipts, grants, and conversations shared for review. Ordinary unshared conversation content is not written to that state file. Shared AI reviews are bounded to 200 records and 4 MiB overall and persist until replaced or removed; public server-chat buffers have separate 200-record/4-MiB memory limits and expire after ten minutes. Raw IPs are not stored in the relay state. The operator's hosting logs are separate.

Offline checks include 16 public-profile cases, 15 public-chat observer cases, and 53 client integration cases. They cover URL/credential boundaries, field validation, timeouts/cache limits, channel/source exclusion, sharing choices before Open AI Build, rolling limits/expiration, in-flight withdrawal, single-timer behavior, selected-player remote reads, owner model/effort authorization, and cleanup. They do not establish live HTTP/executor compatibility or that a remote sharing client is currently connected.

## What has and has not been demonstrated live

- **Observed/reported before this expanded release:** an initial client placed 12 car parts. A live relay request produced a valid small plan and reduced its allowance. These demonstrate basic connectivity/placement and charging, not the full new feature set.
- **Relay health checked for this release:** the running relay reported version 0.3.0. This confirms the health/version endpoint; it does not by itself validate model availability, shared-chat workflows, or the full owner timeout path.
- **Known earlier failures addressed in source:** unsupported Lamp resize now fails before dispatch; vehicle context now includes native geometry guidance and the plan path supports full native vehicle bindings. The old car's poor wheel orientation/binding result is not converted into a verified driving success by a source change.
- **Still needs live acceptance:** the latest GUI in the chosen executor, inspector Source/native provider behavior, a correctly oriented and attached vehicle with working steering/drive, Button-driven piston motion, new saved-plan operation flows, authenticated owner model/profile/review/presence/grant/join actions, and full-length owner requests through the HTTPS proxy. Remote public-chat review needs another sharing client and current delivered General-channel messages.
- **Not provided:** Premium, unrestricted access to every model, arbitrary Lua execution, unreplicated server source, hidden server administration, unlimited inventory, other players' build editing, arbitrary direct piston/switch invocation, individual Boolean Push/Pull verification, automatic native Roblox save-slot saving, private-chat capture, arbitrary remote-server inspection, or a full-game export.
- **Not a model-training deliverable:** calculator lessons are structured relay instructions and contextual guidance. No new model weights, fine-tune, or guaranteed calculator/vehicle competence is claimed.

For vehicle acceptance, inspect wheel axle direction, body/tire clearance, native mount relationships, full input mapping, motor direction, steering, and actual controlled movement. A static preview, placed parts, accepted bindings, changed piston properties, or a successful offline test cannot alone establish a functioning vehicle.

For release acceptance, install the matching relay, confirm its health/version, use the new loader, complete a small build, reload saved chats/plans, and exercise the intended operations in the actual game. Preserve completed work and inspect uncertain results before preparing another plan.
