#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Fails if a release artifact (APK or AAB) is signed with the Android debug key.
#
# Google Play rejects those with:
#   "You uploaded an APK or Android App Bundle that was signed in debug mode.
#    You need to sign your APK or Android App Bundle in release mode."
#
# Usage:
#   tools/verify_release_signing.sh build/app/outputs/bundle/release/app-release.aab
#   tools/verify_release_signing.sh build/app/outputs/flutter-apk/app-release.apk
#
# Requires: unzip + keytool (any JDK).
# ---------------------------------------------------------------------------
set -euo pipefail

artifact="${1:-}"

if [[ -z "$artifact" ]]; then
  echo "usage: $0 <app-release.aab|app-release.apk>" >&2
  exit 2
fi
if [[ ! -f "$artifact" ]]; then
  echo "error: artifact not found: $artifact" >&2
  exit 2
fi
for tool in unzip keytool; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: '$tool' not found (install unzip and a JDK)" >&2
    exit 2
  fi
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "==> Signing certificate of $artifact"

# Collect the JAR-signature files inside the archive (META-INF/*.RSA|DSA|EC).
certs=()
while IFS= read -r entry; do
  if [[ -n "$entry" ]]; then
    certs+=("$entry")
  fi
done < <(unzip -l "$artifact" | awk '{print $NF}' | grep -Ei '^META-INF/[^/]+\.(RSA|DSA|EC)$' || true)

if [[ ${#certs[@]} -eq 0 ]]; then
  # Last resort: let keytool look for it itself (works for some bundle layouts).
  if ! keytool -printcert -jarfile "$artifact" >/dev/null 2>&1; then
    echo "error: no signing certificate found in $artifact" >&2
    echo "       either the artifact is unsigned, or it is not an APK/AAB" >&2
    exit 1
  fi
  echo "    (certificate located via keytool -jarfile)"
fi

debug_signed=0
found=0
index=0
if [[ ${#certs[@]} -gt 0 ]]; then
for entry in "${certs[@]}"; do
  index=$((index + 1))
  if ! unzip -p "$artifact" "$entry" > "$tmp/cert-$index.der" 2>/dev/null; then
    continue
  fi
  cert_file="$tmp/cert-$index.der"
  out="$(keytool -printcert -v -file "$cert_file" 2>/dev/null || true)"
  [[ -n "$out" ]] || continue
  found=1

  owner="$(grep -m1 -iE '^[[:space:]]*Owner:' <<<"$out" || true)"
  echo "    $entry"
  echo "      ${owner:-<no Owner line found>}"
  while IFS= read -r fp; do
    if [[ -n "$fp" ]]; then
      echo "      $fp"
    fi
  done < <(grep -iE '^[[:space:]]+(SHA1|SHA256):' <<<"$out" | sed -E 's/^[[:space:]]+//' || true)

  if [[ "$owner" == *"Android Debug"* ]]; then
    debug_signed=1
  fi
done
fi

if [[ ${#certs[@]} -eq 0 ]]; then
  out="$(keytool -printcert -v -jarfile "$artifact" 2>/dev/null || true)"
  owner="$(grep -m1 -iE '^[[:space:]]*Owner:' <<<"$out" || true)"
  echo "    ${owner:-<no Owner line found>}"
  while IFS= read -r fp; do
    if [[ -n "$fp" ]]; then
      echo "      $fp"
    fi
  done < <(grep -iE '^[[:space:]]+(SHA1|SHA256):' <<<"$out" | sed -E 's/^[[:space:]]+//' || true)
  if [[ "$owner" == *"Android Debug"* ]]; then
    debug_signed=1
  fi
  found=1
fi

if [[ "$found" -ne 1 ]]; then
  echo "error: could not read any signing certificate from $artifact" >&2
  exit 1
fi

if [[ "$debug_signed" -eq 1 ]]; then
  cat >&2 <<'EOF'

error: this artifact is signed with the ANDROID DEBUG KEY.
Google Play will reject it with:
  "You uploaded an APK or Android App Bundle that was signed in debug mode.
   You need to sign your APK or Android App Bundle in release mode."

Rebuild it with your upload keystore configured — see README.md > "Release signing":
  bash tools/create_release_keystore.sh   # local builds
  GitHub secrets KEYSTORE_BASE64 / KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD   # CI
EOF
  exit 1
fi

echo "OK: signed with a non-debug (upload) key."
