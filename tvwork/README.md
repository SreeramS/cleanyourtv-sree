# Sony BRAVIA VU2 — cleanup and Apple TV style Home (17 Nov 2026)

TV: Sony BRAVIA VU2 (BRAVIA_VU1_4K), Android TV 14 (SDK 34), build UKR1.240726.001, IP 192.168.29.174 (Wi-Fi "home 5g").
Tools: the cleanyourtv repo in `~/SreeProjects/cleanyourtv` (following its `examples/sony-bravia-vu2`).
Everything was **disabled, not uninstalled**, so anything can be switched back on.

## What changed
| Batch | Disabled |
|---|---|
| 1 telemetry | Google feedback, partner setup, one-time initializer, Sony retail demo |
| 2 unused system | calendar sync + storage, print spooler, camera, gallery, live wallpaper picker |
| 3 apps you don't use | YouTube Music, Apple TV, Sun NXT, JioTV+, Waves, Play Movies & TV |
| 4 after new Home | stock Google TV launcher, its recommendation rows, Ambient screensaver |

Kept on purpose: YouTube, Netflix, Prime Video, JioHotstar, ZEE5, Sony LIV, Spotify, Google Assistant,
Chromecast, system updates, Play Store/Services, all TV input/tuner/remote services.

Other changes:
- New Home: `com.gathin.tvhome` (cleanyourtv launcher, built locally with two changes, see below). Dock: YouTube, ZEE5,
  JioHotstar, Netflix, Prime Video; 5 columns; focus style `green-glass` — all set by the theme in `dock-theme/config.json`
  (it overrides config.xml).
- Screensaver: the launcher's clock (`com.gathin.tvhome/.ClockDream`) instead of Ambient.
- Private DNS: `dns.adguard-dns.com` (blocks ad/tracker domains; **not** YouTube ads).
- HDMI 1–3 stay hidden in the Inputs menu because the TV's own settings hide them (your choice).
- Every remote button (Home, Input, Settings, mic, Netflix, YouTube, Prime Video) works; held Volume + still ramps.
- After a reboot the firmware re-enabled nothing, and the TV boots straight into the new Home.

The lists are in `lists/`, the original state in `backup/` (packages, getprop, all settings), screenshots in `shots/`.

## Commands need USB debugging on
I switched debugging off at the end. To run any command below, turn **USB debugging** back on
(Settings > System > Developer options), run the command from `~/SreeProjects/cleanyourtv`, accept the prompt on the TV,
and switch it off again afterwards.

```bash
cd ~/SreeProjects/cleanyourtv && export TV_HOST=192.168.29.174
```

## Re-enable one app
```bash
tools/venv/bin/python -I tools/tv.py 'pm enable --user 0 com.google.android.youtube.tvmusic'
```
Package names are in the files in `../tvwork/lists/`. To re-enable a whole batch: `tools/restore.sh ../tvwork/lists/3-unused-streaming.txt`.
To undo **everything** (including DNS and screensaver): `../tvwork/restore-all.sh 192.168.29.174`.

Turn off the ad-blocking DNS only:
```bash
tools/venv/bin/python -I tools/tv.py 'settings put global private_dns_mode opportunistic'
```

## Change the dock order or apps
Quickest, no rebuild: edit `dock_apps` / `columns` in `~/SreeProjects/tvwork/dock-theme/config.json`, then
`tools/theme.sh ../tvwork/dock-theme`. While that theme is on the TV it wins over config.xml;
`tools/theme.sh --reset` drops it.

Or edit `dock_apps` (and `columns` for 5–7 slots) in
`launcher/app/src/main/res/values/config.xml`, then run `../tvwork/build-and-install.sh 192.168.29.174`.
Common package names: YouTube `com.google.android.youtube.tv`, Netflix `com.netflix.ninja`,
Prime Video `com.amazon.amazonvideo.livingroom`, JioHotstar `in.startv.hotstar`, ZEE5 `com.graymatrix.did`,
Sony LIV `com.sonyliv`, Spotify `com.spotify.tv.android`.

## Change the wallpaper
Wallpapers are pushed as a theme, with no rebuild:
```bash
cp -R themes/default ~/my-tv-theme            # a theme folder of your own, outside the repo
cp ~/Pictures/some-photo.jpg ~/my-tv-theme/wallpaper.jpg
tools/theme.sh ~/my-tv-theme                   # pushes it and restarts Home
tools/theme.sh --reset                         # back to the plain black Home
```
Ready-made looks: `tools/theme.sh themes/aurora` (and the others in `themes/README.md`). The dock order can also go
in that theme's `config.json` (`"dock_apps": [...]`).

## Firmware updates
A Sony/Google system update can re-enable some packages. If junk comes back, re-run a list, e.g.
`tools/disable.sh ../tvwork/lists/1-telemetry.txt`.

## Local launcher changes (17 Nov 2026)
Built from `~/SreeProjects/cleanyourtv` with uncommitted changes (`git diff` there; full copy in `all-changes.patch`):
1. **Blank Home after a quick power off/on — fixed.** The tuner's Automatic Service Update (`com.realtek.dtv`) opens
   its Digital Channel Setup screen at every power-off; a quick power-on left Home without tiles, highlight or name,
   and sometimes not drawing at all (`mLastPerformDrawFailedReason=screen_off`). Home now checks it draws after each
   screen-on/focus: if not, it restarts its own process (log tag `TvHome`, once a minute at most); otherwise it
   repairs stuck tiles/fades. Keep ASU on — it's no longer a problem. `com.realtek.dtv` must never be disabled.
2. **Green focus styles:** `glass_style` also takes `green-glass` (your default), `green-halo`, `green-rim`.
   Change it in `dock-theme/config.json`, then `tools/theme.sh ../tvwork/dock-theme` (no rebuild).
Your own settings in `config.xml`: dock order, `live_tv_package` = com.android.tv, `com.android.tv` hidden, default `green-glass`.
Originals of changed files: `backup/*.orig`. Upstream issue/PRs: `upstream/STEPS.md`.

If Home ever comes up blank anyway: press an arrow key, or restart the launcher:
`tools/venv/bin/python -I tools/tv.py 'am force-stop com.gathin.tvhome'` (then press Home).
