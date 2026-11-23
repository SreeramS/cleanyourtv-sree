#!/bin/bash
# usage: j.sh <timeout> <tool> [args...]   (stdin optional via STDIN_FILE)
cd "$(dirname "$0")"
n=$(( $(ls results/*.rc 2>/dev/null | wc -l) + $(ls queue/*.job 2>/dev/null | wc -l) + 1 ))
id=$(printf '%03d' $n); while [ -e queue/$id.job.taken ] || [ -e queue/$id.job ]; do n=$((n+1)); id=$(printf '%03d' $n); done
t=$1; shift
python3 - "$id" "$t" "$@" <<'PY'
import json,sys,os
id,t,*argv=sys.argv[1:]
job={"argv":argv,"timeout":int(t)}
if os.environ.get("STDIN_FILE"): job["stdin"]=open(os.environ["STDIN_FILE"]).read()
json.dump(job,open(f"queue/{id}.tmp","w")); os.replace(f"queue/{id}.tmp",f"queue/{id}.job")
PY
for i in $(seq 1 $((t+30))); do [ -f results/$id.rc ] && break; sleep 1; done
cat results/$id.out 2>/dev/null; echo "[job $id rc=$(cat results/$id.rc 2>/dev/null || echo TIMEOUT)]"
