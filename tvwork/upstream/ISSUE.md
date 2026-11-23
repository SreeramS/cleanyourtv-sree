# Home comes back blank (no tiles, glass or name) after a quick power off and on — Sony BRAVIA VU2

## Device
- Sony BRAVIA VU2 (`BRAVIA_VU1_4K`, Realtek `rtd2885m`), India
- Android TV 14 (SDK 34), build `UKR1.240726.001`
- `examples/sony-bravia-vu2/debloat.txt` applied, `launcher/` as Home (theme: 5 columns, `glass_style`)

## What happens
1. Press power off on the remote, then power on within a second or two.
2. Home comes back with the top bar (clock, Inputs, Wi-Fi, Settings) and the empty dock band, but **no tiles, no
   focus highlight and no app name**.
3. An arrow key brings the tiles back, but not the highlight or the name. Pressing Home does not help either.
4. `am force-stop com.gathin.tvhome` (a new process) brings everything back; `recreate()` does not.

A slow cycle (the TV asleep for a minute or more) comes back normally.

## Cause
- **Trigger:** the tuner's Automatic Service Update (`com.realtek.dtv` `ASUService.onAsuIsTriggered`) starts
  `com.realtek.dtv/.DigitalSetup.DigitalChannelSetupActivity` at every power-off (`START u0 ... from uid 1000`). On
  a quick power-on, that screen is on top for about half a second and then finishes. Home is paused, stopped,
  restarted and resumed while its window is still `NOT_VISIBLE`.
- **Stuck fades:** the refocus in `reloadApps()` runs before the grid is laid out, so it finds no tile. The glass
  and hero fades it starts stay at alpha 0 while `glassShown` and `heroShown` say shown. Nothing retries them. The
  tiles' layout animation never gets a frame.
- **No drawing at all:** the process can also miss the display's ON event. Every window in it then skips each
  draw. `dumpsys activity top` shows `mLastPerformDrawFailedReason=screen_off` with `mHasWindowFocus=true`
  `mWindowVisibility=0`. `dumpsys gfxinfo com.gathin.tvhome` stops counting frames and the clock stops. The stale
  state belongs to the process, which is why only a new process recovers.

## Evidence (logcat -b events)
```
I/screen_toggled: 0
I/wm_set_resumed_activity: [0,com.realtek.dtv/.DigitalSetup.DigitalChannelSetupActivity,...]
I/screen_toggled: 1
I/wm_set_resumed_activity: [0,com.gathin.tvhome/.MainActivity,finish-top adjustFocusToNextFocusableTask]
I/wm_on_restart_called / wm_on_start_called / wm_on_resume_called: com.gathin.tvhome.MainActivity
I/input_focus: [Focus entering ... MainActivity ..., Previous reason: NOT_VISIBLE]
```

## Workaround without the fix
Turn off the tuner's Automatic Service Update in the TV settings, if you don't need it. `com.realtek.dtv` must stay
enabled: it is the tuner.

## Fix
PR: "launcher: repair a blank Home after a quick power off and on". After each screen-on and window focus, Home asks
for one draw:

- **No frame while the TV is awake** (`PowerManager.isInteractive()`): it restarts its process, at most once a
  minute, logged as `TvHome`. Android relaunches the top Home.
- **Otherwise:** it repairs stuck tiles and fades through the existing refocus path.

Tested with quick power cycles, an app round trip, and quick power cycles after a TV restart.
