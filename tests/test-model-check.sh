#!/usr/bin/bash
# Tests the HINDSIGHT_API_LLM_MODEL extraction that hooks/check-health uses to
# decide whether to fail SDK health (empty -> set-health error). The extractor
# here MUST stay identical to the sed in hooks/check-health.
#
# Run: bash tests/test-model-check.sh
set -uo pipefail

extract() {
    sed -n 's/^[[:space:]]*HINDSIGHT_API_LLM_MODEL[[:space:]]*=[[:space:]]*//p' | tail -1
}

fail=0
check() {  # name  got  want
    if [ "$2" != "$3" ]; then
        echo "FAIL $1: got [$2] want [$3]"; fail=1
    else
        echo "PASS $1"
    fi
}

check "blank model -> empty (health error)" \
    "$(printf 'HINDSIGHT_API_LLM_PROVIDER=ollama\nHINDSIGHT_API_LLM_MODEL=\n' | extract)" ""
check "commented model -> empty (health error)" \
    "$(printf '# HINDSIGHT_API_LLM_MODEL=foo\n' | extract)" ""
check "set model -> value (health ok)" \
    "$(printf 'HINDSIGHT_API_LLM_MODEL=qwen3.6:35b\n' | extract)" "qwen3.6:35b"

[ "$fail" -eq 0 ] && echo "ALL PASS" || echo "FAILURES"
exit "$fail"
