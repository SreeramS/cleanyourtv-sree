#!/usr/bin/env python3
"""Runs cleanyourtv's own TV tools on request, for Claude, and nothing else.

Usage (from ~/SreeProjects):  cleanyourtv/tools/venv/bin/python -I tvwork/runner.py <TV IP>
Claude drops a job file in tvwork/queue/; this runs it from cleanyourtv/ and writes the
output to tvwork/results/. Only the scripts in ALLOWED can run, with no shell. Ctrl-C stops it.
"""
import json, os, subprocess, sys, time
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(os.path.dirname(HERE), "cleanyourtv")
PY = os.path.join(REPO, "tools", "venv", "bin", "python")
ALLOWED = {"tv.py": [PY, "-I"], "adb-closed.py": [PY, "-I"], "b64push.py": [PY, "-I"],
           "disable.sh": ["bash"], "restore.sh": ["bash"], "theme.sh": ["bash"]}
if len(sys.argv) != 2:
    sys.exit("usage: runner.py <TV IP or IP:port>")
env = dict(os.environ, TV_HOST=sys.argv[1])
q, r = os.path.join(HERE, "queue"), os.path.join(HERE, "results")
print(f"Runner up for TV {sys.argv[1]}. Leave this window open; Ctrl-C to stop.", flush=True)
while True:
    for name in sorted(os.listdir(q)):
        if not name.endswith(".job"):
            continue
        path = os.path.join(q, name); jid = name[:-4]
        try:
            job = json.load(open(path)); os.replace(path, path + ".taken")
            tool, args = job["argv"][0], [str(a) for a in job["argv"][1:]]
            if tool not in ALLOWED:
                raise ValueError(f"tool not allowed: {tool}")
            cmd = ALLOWED[tool] + [os.path.join("tools", tool)] + args
            print(f"[{jid}] {tool} {' '.join(args)[:100]}", flush=True)
            p = subprocess.run(cmd, cwd=REPO, env=env, input=job.get("stdin", ""), text=True,
                               capture_output=True, timeout=job.get("timeout", 600))
            out, rc = p.stdout + ("\n--- stderr ---\n" + p.stderr if p.stderr else ""), p.returncode
        except Exception as e:
            out, rc = f"runner error: {e!r}", -1
        with open(os.path.join(r, jid + ".tmp"), "w") as f:
            f.write(out)
        os.replace(os.path.join(r, jid + ".tmp"), os.path.join(r, jid + ".out"))
        open(os.path.join(r, jid + ".rc"), "w").write(str(rc))
    time.sleep(0.5)
