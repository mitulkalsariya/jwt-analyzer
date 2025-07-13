#!/bin/bash

# Usage: ./jwt-analyzer.sh --token <JWT> [--verbose]

show_help() {
  echo "Usage: $0 --token <JWT> [--verbose]"
  echo "  --token <JWT>     JWT token to analyze"
  echo "  --verbose         Show decoded header and payload"
  echo "  --help            Show help"
  exit 0
}

JWT=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --token)
      JWT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      show_help
      ;;
    *)
      echo "[!] Unknown option: $1"
      show_help
      ;;
  esac
done

if [[ -z "$JWT" ]]; then
  echo "[!] JWT token not provided"
  show_help
fi

IFS='.' read -r HEADER_B64 PAYLOAD_B64 SIGNATURE <<< "$JWT"

decode_b64url() {
  local b64="$1"
  while (( ${#b64} % 4 != 0 )); do b64+="="; done
  echo "$b64" | tr '_-' '/+' | base64 -d 2>/dev/null
}

header=$(decode_b64url "$HEADER_B64")
payload=$(decode_b64url "$PAYLOAD_B64")

if $VERBOSE; then
  echo -e "\n===== HEADER ====="
  echo "$header"
  echo -e "\n===== PAYLOAD ====="
  echo "$payload"
fi

echo -e "\n===== FINDINGS ====="

# Extract fields
alg=$(echo "$header" | jq -r .alg 2>/dev/null)
exp=$(echo "$payload" | jq -r .exp 2>/dev/null)
iat=$(echo "$payload" | jq -r .iat 2>/dev/null)
iss=$(echo "$payload" | jq -r .iss 2>/dev/null)
aud=$(echo "$payload" | jq -r .aud 2>/dev/null)
jti=$(echo "$payload" | jq -r .jti 2>/dev/null)
now=$(date +%s)

# STRUCTURE
[[ $(echo "$JWT" | grep -o '\.' | wc -l) -ne 2 ]] && echo "[CRITICAL] Token should have 3 parts"
[[ "$JWT" =~ " " ]] && echo "[MEDIUM] Token contains whitespace"
[[ -z "$SIGNATURE" ]] && echo "[CRITICAL] Missing signature"

# ALGORITHM CHECKS
if [[ "$alg" == "none" ]]; then
  echo "[CRITICAL] alg=none - no signature verification"
elif [[ "$alg" =~ ^HS ]]; then
  echo "[INFO] HMAC algorithm ($alg) - secure if key is strong and server expects it"
elif [[ -z "$alg" || "$alg" == "null" ]]; then
  echo "[CRITICAL] Algorithm missing from header"
else
  echo "[+] Algorithm: $alg"
fi

# SIGNATURE LENGTH
[[ ${#SIGNATURE} -lt 20 ]] && echo "[HIGH] Signature too short"
[[ "$SIGNATURE" =~ (secret|test|123456) ]] && echo "[CRITICAL] Signature contains weak string"

# TIME CLAIMS
if [[ "$exp" =~ ^[0-9]+$ ]]; then
  (( exp < now )) && echo "[HIGH] Token expired"
  (( exp > now + 31536000 )) && echo "[LOW] Expiration > 1 year - ensure revocation process exists"
else
  echo "[HIGH] No exp claim - token may never expire"
fi

if [[ "$iat" =~ ^[0-9]+$ ]]; then
  (( iat > now )) && echo "[HIGH] iat is in the future"
else
  echo "[LOW] No iat (issued-at) claim"
fi

# CLAIM VALIDATION
[[ -z "$iss" || "$iss" == "null" ]] && echo "[MEDIUM] Missing issuer (iss)"
[[ -z "$aud" || "$aud" == "null" ]] && echo "[MEDIUM] Missing audience (aud)"
[[ -z "$jti" || "$jti" == "null" ]] && echo "[LOW] Missing JWT ID (jti)"

# PII & SENSITIVE DATA
echo "$payload" | grep -Eiq 'password|api[_-]?key|secret|private|ssn|creditcard' && echo "[CRITICAL] Sensitive data found in payload"

# ROLE CHECK
echo "$payload" | grep -Eiq '"role"\s*:\s*"?(admin|root|superuser)' && echo "[HIGH] Privileged role in token"

# PII DETECTION
echo "$payload" | grep -Eiq '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-zA-Z]{2,}\b' && echo "[LOW] Email address detected (PII)"
echo "$payload" | grep -Eiq '\b\d{3}[-.\s]?\d{2}[-.\s]?\d{4}\b' && echo "[HIGH] SSN pattern detected"
echo "$payload" | grep -Eiq '\b\d{16}\b' && echo "[HIGH] Credit card number detected"

# STORAGE RECOMMENDATIONS
echo "[INFO] Recommended: Store JWTs in httpOnly, secure cookies"
echo "[INFO] Avoid storing JWTs in localStorage or URL parameters"
echo "[INFO] Always transmit JWTs over HTTPS"

echo -e "\n[✓] Analysis complete."
