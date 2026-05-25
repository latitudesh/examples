#!/usr/bin/env bash
# Smoke test for the k8s-demo-app chat orchestrator.
#
# Usage:
#   BASE=http://1.2.3.4 ./smoke-test.sh
#   ./smoke-test.sh                # auto-detects via kubectl
#
# Exits non-zero on any failure.

set -euo pipefail

if [ -z "${BASE:-}" ]; then
  IP=$(kubectl get svc -n ai-demo llama-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  if [ -z "$IP" ]; then
    echo "BASE is not set and kubectl could not find an external IP for svc/llama-external in ai-demo." >&2
    exit 2
  fi
  BASE="http://$IP"
fi

SESSION="smoke-$(date +%s)-$RANDOM"
PASS=0
FAIL=0

ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

echo "Target: $BASE"

echo "== /health =="
if curl -fsS "$BASE/api/health" | grep -q '"status":"ok"'; then ok "backend /api/health"; else fail "backend /api/health"; fi

echo "== /models =="
MODELS=$(curl -fsS "$BASE/api/models")
echo "  $MODELS"
echo "$MODELS" | grep -q '"qwen"'   && ok "qwen listed"   || fail "qwen missing"
echo "$MODELS" | grep -q '"hermes"' && ok "hermes listed" || fail "hermes missing"

for model in qwen hermes; do
  echo "== /chat?model=$model (streaming) =="
  TMP=$(mktemp)
  curl -fsS -N -X POST "$BASE/api/chat?session_id=$SESSION&model=$model" \
    -H 'Content-Type: application/json' \
    -d '{"message":"Reply with exactly the word: pong"}' \
    -o "$TMP"
  if grep -q '"event": *"delta"' "$TMP" && grep -q '\[DONE\]' "$TMP"; then
    ok "$model streamed deltas and completed"
  else
    fail "$model did not stream cleanly"
    head -20 "$TMP" | sed 's/^/      /'
  fi
  rm -f "$TMP"
done

echo "== /history =="
TURNS=$(curl -fsS "$BASE/api/history?session_id=$SESSION" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["turns"]))')
[ "$TURNS" -ge 4 ] && ok "history has $TURNS turns (>=4 expected)" || fail "history has only $TURNS turns"

echo "== /reset =="
curl -fsS -X POST "$BASE/api/reset?session_id=$SESSION" >/dev/null
AFTER=$(curl -fsS "$BASE/api/history?session_id=$SESSION" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["turns"]))')
[ "$AFTER" -eq 0 ] && ok "history cleared after /reset" || fail "history not cleared ($AFTER turns remain)"

echo
echo "Summary: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
