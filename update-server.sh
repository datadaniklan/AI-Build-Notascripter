#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ ${EUID} -eq 0 ]] || { echo 'Run: sudo bash update-server.sh'; exit 1; }
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR=/opt/forgeai
NODE_BIN="$(command -v node || true)"
[[ -n "$NODE_BIN" ]] || { echo 'Install system-wide Node.js 22 or newer first.' >&2; exit 1; }
NODE_MAJOR="$("$NODE_BIN" -p 'Number(process.versions.node.split(".")[0])')"
[[ "$NODE_MAJOR" =~ ^[0-9]+$ ]] && (( NODE_MAJOR >= 22 )) || { echo 'Node.js 22 or newer is required.' >&2; exit 1; }
[[ -f "$DEST_DIR/.env" && -f "$DEST_DIR/server.mjs" ]] || { echo 'Existing /opt/forgeai installation not found.'; exit 1; }
"$NODE_BIN" --check "$SOURCE_DIR/server.mjs"
QUOTA_FILE="$(env -u FORGE_STATE_FILE "$NODE_BIN" --env-file="$DEST_DIR/.env" -e 'process.stdout.write(require("node:path").resolve(process.argv[1],process.env.FORGE_STATE_FILE||"./forgeai-quota.json"))' "$DEST_DIR")"
BACKUP_DIR="$(mktemp -d "$DEST_DIR/backup-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")"
cp -p "$DEST_DIR/server.mjs" "$DEST_DIR/.env" "$BACKUP_DIR/"
if [[ -f "$DEST_DIR/admin-token.txt" ]]; then cp -p "$DEST_DIR/admin-token.txt" "$BACKUP_DIR/"; fi
rollback() {
  echo 'Update failed; attempting to restore the previous server and environment.' >&2
  cp -p "$BACKUP_DIR/server.mjs" "$DEST_DIR/server.mjs" || true
  cp -p "$BACKUP_DIR/.env" "$DEST_DIR/.env" || true
  if [[ -f "$BACKUP_DIR/admin-token.txt" ]]; then cp -p "$BACKUP_DIR/admin-token.txt" "$DEST_DIR/admin-token.txt" || true
  else rm -f -- "$DEST_DIR/admin-token.txt" || true; fi
  # Keep any accepted quota/grant records from the new process. Version-1
  # records remain compatible with the previous relay; never reset usage.
  systemctl restart forgeai.service || true
}
trap rollback ERR
systemctl stop forgeai.service
if [[ -f "$QUOTA_FILE" ]]; then cp -p "$QUOTA_FILE" "$BACKUP_DIR/forgeai-quota.json"; fi
ADMIN_TOKEN="$(env -u FORGE_ADMIN_TOKEN "$NODE_BIN" --env-file="$DEST_DIR/.env" -e 'const token=process.env.FORGE_ADMIN_TOKEN||"";if(token.length>=32&&token.length<=256&&!/\s/.test(token))process.stdout.write(token)')"
if [[ -z "$ADMIN_TOKEN" ]]; then
  ADMIN_TOKEN="$("$NODE_BIN" -e 'process.stdout.write(require("node:crypto").randomBytes(32).toString("hex"))')"
  sed -Ei '/^[[:space:]]*(export[[:space:]]+)?FORGE_ADMIN_TOKEN[[:space:]]*=/d' "$DEST_DIR/.env"
  printf '\nFORGE_ADMIN_TOKEN=%s\n' "$ADMIN_TOKEN" >> "$DEST_DIR/.env"
fi
printf '%s\n' "$ADMIN_TOKEN" > "$DEST_DIR/admin-token.txt"
chown root:root "$DEST_DIR/admin-token.txt"
chmod 600 "$DEST_DIR/admin-token.txt"
unset ADMIN_TOKEN
chown forgeai:forgeai "$DEST_DIR/.env"
chmod 600 "$DEST_DIR/.env"
install -m 644 -o root -g forgeai "$SOURCE_DIR/server.mjs" "$DEST_DIR/server.mjs"
systemctl restart forgeai.service
sleep 2
systemctl is-active --quiet forgeai.service
env -u PORT "$NODE_BIN" --env-file="$DEST_DIR/.env" --input-type=module -e 'const port=Number(process.env.PORT||3000);if(!Number.isSafeInteger(port)||port<1||port>65535)process.exit(1);const r=await fetch("http://127.0.0.1:"+port+"/health",{signal:AbortSignal.timeout(5000)});const j=await r.json();if(!r.ok||j.relayVersion!=="0.3.3"||!j.adminEnabled)process.exit(1);console.log("AI Build relay 0.3.3: healthy; admin authentication enabled.")'
trap - ERR
echo 'Updated. Existing OpenAI key and quotas are preserved.'
echo 'The private owner token is in /opt/forgeai/admin-token.txt (root-only).'
echo 'Enter that token in your in-game Admin panel; never post it publicly.'
echo 'Public health: https://r.eggsmp.gg/forgeai/health'
