#!/bin/bash
# Evaluate and build upstream HighWire changes for the SAM TT030 fork (operator 2026-10-17: "ensure upstream fixes are
# evaluated and built").
#   packaging/upstream-sync.sh SIDE_REPO [--merge]
# 1. fetches upstream (github.com/neilrackett/atarist-highwire) and lists commits on upstream/main not yet in sam-tt030;
# 2. with --merge: merges them on a throwaway branch upstream-eval/<date>, builds with build-tt030.sh, and reports
#    merge conflicts or build failures. Nothing is pushed: a human (or agent) reviews the report, tests on the TT,
#    then fast-forwards sam-tt030 and bumps the -samN suffix. Exit: 0 nothing new or merged+built · 1 conflict/build
#    failure (named) · 2 usage. Silence is never success: "nothing new" is printed explicitly.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd); S=${1:?usage: upstream-sync.sh SIDE_REPO [--merge]}; mode=${2:-}
cd "$here"
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream https://github.com/neilrackett/atarist-highwire.git
git fetch -q upstream
new=$(git rev-list --count sam-tt030..upstream/main)
echo "upstream-sync: $(date -u +%FT%TZ) upstream/main $(git rev-parse --short upstream/main), $new commit(s) not in sam-tt030"
[ "$new" = 0 ] && { echo "upstream-sync: nothing new"; exit 0; }
git log --oneline --no-merges sam-tt030..upstream/main
git diff --stat sam-tt030...upstream/main | tail -1
[ "$mode" = "--merge" ] || { echo "upstream-sync: run with --merge to test-merge and build"; exit 0; }
b=upstream-eval/$(date -u +%Y%m%d)
git checkout -q -B "$b" sam-tt030
if ! git merge -q --no-edit upstream/main; then
    echo "upstream-sync: MERGE CONFLICT on $b:"; git diff --name-only --diff-filter=U; git merge --abort; exit 1
fi
if ! bash packaging/build-tt030.sh "$S"; then echo "upstream-sync: BUILD FAILED on $b"; exit 1; fi
echo "upstream-sync: $b merged and built; next: test on the TT, then fast-forward sam-tt030 and bump -samN"
