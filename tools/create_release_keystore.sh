#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Creates the UPLOAD keystore used to sign release builds of this app, writes
# android/key.properties, and prints the values you need as GitHub secrets.
#
#   bash tools/create_release_keystore.sh            # create keystore + config
#   bash tools/create_release_keystore.sh --export   # print secrets for an
#                                                    # existing keystore
#
# Requires: keytool (any JDK).
#
# The keystore and android/key.properties are git-ignored — never commit them.
# BACK THEM UP (password manager / offline backup). With Play App Signing you
# can ask Google to reset a lost upload key, but it takes days and requires
# proof of identity.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$REPO_ROOT/android"
KEYSTORE="${KEYSTORE:-$ANDROID_DIR/app/upload-keystore.jks}"
KEY_PROPS="$ANDROID_DIR/key.properties"
ALIAS="${KEY_ALIAS:-upload}"
VALIDITY_DAYS="${VALIDITY_DAYS:-10000}"
DNAME="${DNAME:-CN=Malama Zainab Jaafar Muhadara 2, OU=Mobile, O=Nakudin, C=NG}"

random_password() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 32 | tr -d '/+=' | head -c 24
  else
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24
  fi
}

command -v keytool >/dev/null 2>&1 || {
  echo "error: keytool not found — install a JDK first" >&2
  exit 2
}

# --------------------------------------------------------------------------
# --export: just print the secrets for a keystore that already exists
# --------------------------------------------------------------------------
if [[ "${1:-}" == "--export" ]]; then
  store_pass="${KEYSTORE_PASSWORD:-}"
  key_alias="${KEY_ALIAS:-}"
  key_pass="${KEY_PASSWORD:-}"
  if [[ -f "$KEY_PROPS" ]]; then
    # shellcheck disable=SC1090
    [[ -z "$store_pass" ]] && store_pass="$(sed -n 's/^storePassword=//p' "$KEY_PROPS")"
    [[ -z "$key_alias" ]] && key_alias="$(sed -n 's/^keyAlias=//p' "$KEY_PROPS")"
    [[ -z "$key_pass" ]] && key_pass="$(sed -n 's/^keyPassword=//p' "$KEY_PROPS")"
    ks_path="$(sed -n 's/^storeFile=//p' "$KEY_PROPS")"
    [[ -n "$ks_path" ]] && KEYSTORE="$ANDROID_DIR/app/$ks_path"
  fi
  [[ -f "$KEYSTORE" ]] || { echo "error: keystore not found: $KEYSTORE" >&2; exit 2; }
else
  # ------------------------------------------------------------------------
  # Create a fresh keystore
  # ------------------------------------------------------------------------
  if [[ -f "$KEYSTORE" ]]; then
    echo "error: $KEYSTORE already exists."
    echo "       Refusing to overwrite it — losing this file means you can no longer"
    echo "       publish updates to your app."
    echo "       To print its secrets instead: KEY_ALIAS=... bash $0 --export"
    exit 1
  fi

  STORE_PASSWORD="${KEYSTORE_PASSWORD:-$(random_password)}"
  KEY_PASSWORD="${KEY_PASSWORD:-$(random_password)}"

  echo "==> Creating upload keystore: $KEYSTORE"
  keytool -genkeypair -v \
    -keystore "$KEYSTORE" \
    -storetype PKCS12 \
    -keyalg RSA -keysize 2048 \
    -validity "$VALIDITY_DAYS" \
    -alias "$ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

  cat > "$KEY_PROPS" <<EOF
storeFile=$(basename "$KEYSTORE")
storePassword=$STORE_PASSWORD
keyAlias=$ALIAS
keyPassword=$KEY_PASSWORD
storeType=pkcs12
EOF
  chmod 600 "$KEY_PROPS"
  echo "==> Wrote $KEY_PROPS (mode 600)"

  store_pass="$STORE_PASSWORD"
  key_alias="$ALIAS"
  key_pass="$KEY_PASSWORD"
fi

echo
echo "==> Upload certificate fingerprints"
keytool -list -v -keystore "$KEYSTORE" -alias "$key_alias" -storepass "$store_pass" |
  grep -iE '^(Alias name|Creation date|Entry type)|Certificate fingerprints|Certificate\[|SHA1|SHA256' || true

echo
echo "======================================================================"
echo " GitHub Actions secrets (Settings > Secrets and variables > Actions)"
echo "======================================================================"
echo
echo "KEY_ALIAS          = $key_alias"
echo "KEYSTORE_PASSWORD  = $store_pass"
echo "KEY_PASSWORD       = $key_pass"
echo "KEYSTORE_BASE64    = (see command below, it is too long to print safely)"
echo
echo "Set them with the GitHub CLI (run from the repo root):"
echo
echo "  gh secret set KEY_ALIAS         --body '$key_alias'"
echo "  gh secret set KEYSTORE_PASSWORD --body '$store_pass'"
echo "  gh secret set KEY_PASSWORD      --body '$key_pass'"
echo "  base64 -w0 \"$KEYSTORE\" | gh secret set KEYSTORE_BASE64"
echo
echo "Or paste them into the GitHub UI. Then re-run the 'Build APK' workflow."
echo
echo "BACK UP NOW: $KEYSTORE and the two passwords above."
echo "They are git-ignored and cannot be recovered from this repository."
