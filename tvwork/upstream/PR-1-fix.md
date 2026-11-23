## launcher: repair a blank Home after a quick power off and on (Realtek ASU, Sony BRAVIA VU2)

Fixes #<issue number>.

On a Sony BRAVIA VU2 (Realtek, Android 14 `UKR1.240726.001`), the tuner's Automatic Service Update opens
`com.realtek.dtv/.DigitalSetup.DigitalChannelSetupActivity` at every power-off. A power-on within a second or two
restarts and resumes Home while its window is still invisible, and Home comes back without tiles, glass or name.
The issue has the logs.

### Change (`MainActivity`)
- **Trigger:** an `ACTION_SCREEN_ON` receiver, and `onWindowFocusChanged(true)`, post a check.
- **Draw check:** the check invalidates the root and watches an `OnDrawListener`.
  - **No frame within 600 ms while `PowerManager.isInteractive()`:** the process missed the display's ON event
    (`mLastPerformDrawFailedReason=screen_off`), so it restarts the process with `Process.killProcess`. That
    happens at most once a minute, through a timestamp in SharedPreferences, and is logged as `TvHome`. Android
    relaunches the top Home. `recreate()` was tried first and does not help: the stale state belongs to the
    process.
  - **Frames drawn but something stuck** (tiles mid-entrance, no focus, a focused tile without glass, or glass or
    hero below alpha 1): it clears the tile animations and runs `reloadApps(true, false, false)`, the existing
    refocus path.
- **Untouched cases:** nothing changes when Home is reordering, or the library or a popup is open.
- **Not an app killer** (DOS-AND-DONTS): Home only ever ends its own process, and only when it is visibly unable to
  draw on a TV that is awake. There is no polling and no background service: the work is one broadcast receiver
  and one check after window focus.

### Screenshots (BRAVIA VU2, Wi-Fi name blurred)
- Before, after a quick power cycle: `screenshot-bug-blank-home.jpg`.
- After the fix, after a quick power cycle (theme with `green-glass`): `screenshot-green-glass-after-power-cycle.jpg`.

### Docs
- `docs/TROUBLESHOOTING.md`: a new entry, next to the other black-Home entries.
- `examples/sony-bravia-vu2/debloat.txt`: a power note.

### Tested
On a BRAVIA VU2 (`UKR1.240726.001`):
- Quick power cycles before and after a TV restart.
- An app round trip (JioHotstar → Home).
- `TvHome: repairing Home: ... glass=true/0.0 hero=true/0.0` logged on one cycle, and Home came back complete.

The restart path was exercised before the restart, but its log line was lost with the restart.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01JNks2QG6pJ57GLCSB3q7K5
