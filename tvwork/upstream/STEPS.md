# Sending the fix and the green styles upstream (Gathin23/cleanyourtv)

All files are in `~/SreeProjects/tvwork/upstream/`:

| File | What it is |
|---|---|
| `ISSUE.md` | The issue: bug, cause, evidence, workaround |
| `0001-fix-blank-home-after-quick-power-cycle.patch` | PR 1: the blank-Home fix, with the troubleshooting entry and the VU2 note |
| `PR-1-fix.md` | PR 1 description |
| `0002-green-focus-styles.patch` | PR 2: the green-glass, green-rim and green-halo styles; the default stays `glass` |
| `PR-2-green.md` | PR 2 description |
| `screenshot-*.jpg` | Real-TV screenshots for the PRs, Wi-Fi name blurred |

The patches hold **none of your own settings**: the dock, `live_tv_package`, `hidden_apps` and green-glass as the
default stay only in your TV's copy. Don't commit from `~/SreeProjects/cleanyourtv`, because it carries those
settings. Use a fresh clone of your fork, as below.

## 0. Once: GitHub CLI
```bash
brew install gh && gh auth login        # pick GitHub.com, HTTPS, log in with the browser
```
(Everything below also works on github.com in the browser, as the notes say.)

## 1. Open the issue
```bash
cd ~/SreeProjects/tvwork/upstream
gh issue create -R Gathin23/cleanyourtv \
  --title "Home comes back blank after a quick power off and on (Sony BRAVIA VU2, Realtek ASU)" \
  --body-file ISSUE.md
```
- **Issue number:** note the number it prints (say #4100). Put it in `PR-1-fix.md` in place of `#<issue number>`.
- **Screenshot:** drag `screenshot-bug-blank-home.jpg` into the issue on github.com.

## 2. Fork and clone (once)
In its own folder, so it never mixes with your TV copy:
```bash
mkdir -p ~/SreeProjects/upstream && cd ~/SreeProjects/upstream
gh repo fork Gathin23/cleanyourtv --clone --remote   # origin = your fork, upstream = Gathin23
cd cleanyourtv && git fetch upstream
```
(In the browser: press Fork on github.com/Gathin23/cleanyourtv, then `git clone` your fork, then
`git remote add upstream https://github.com/Gathin23/cleanyourtv`.)

## 3. PR 1: the fix
```bash
git switch -c fix/realtek-asu-blank-home upstream/main
git am --3way ~/SreeProjects/tvwork/upstream/0001-fix-blank-home-after-quick-power-cycle.patch
git commit --amend --reset-author --no-edit      # makes you the author, with your own git name and email
git push -u origin fix/realtek-asu-blank-home
gh pr create -R Gathin23/cleanyourtv --base main --head "$(gh api user -q .login):fix/realtek-asu-blank-home" \
  --title "launcher: repair a blank Home after a quick power off and on (Realtek ASU, Sony BRAVIA VU2)" \
  --body-file ~/SreeProjects/tvwork/upstream/PR-1-fix.md
```
Then open the PR on github.com and drag both `screenshot-*.jpg` files into a comment.

## 4. PR 2: green focus styles (separate, one topic per PR)
```bash
git switch -c feature/green-focus-styles upstream/main
git am --3way ~/SreeProjects/tvwork/upstream/0002-green-focus-styles.patch
git commit --amend --reset-author --no-edit
git push -u origin feature/green-focus-styles
gh pr create -R Gathin23/cleanyourtv --base main --head "$(gh api user -q .login):feature/green-focus-styles" \
  --title "launcher: green-glass, green-rim and green-halo focus styles" \
  --body-file ~/SreeProjects/tvwork/upstream/PR-2-green.md
```
Attach `screenshot-green-glass-after-power-cycle.jpg` to this PR too.

## If `git am` stops with a conflict
`upstream/main` moved since 17 Nov.
1. Fix the files it names.
2. `git add <file>`, then `git am --continue`.
3. `git am --abort` goes back to the start.

## Optional: run the tests before pushing
```bash
python3 -m venv tools/venv && tools/venv/bin/pip install -q -r tools/requirements.txt pytest
tools/venv/bin/python -m pytest -q tests/
```
Known: `tests/test_addon_tested_on_index.py::tested_on_cell` errors on an unchanged `main` too.

## Keeping your TV build in step later
Your `~/SreeProjects/cleanyourtv` keeps your own settings as uncommitted changes. To update it to a newer upstream:
```bash
cd ~/SreeProjects/cleanyourtv
git stash && git pull && git stash pop
```
Then rebuild with `~/SreeProjects/tvwork/build-and-install.sh 192.168.29.174`. Once the PRs are merged, the stash
holds only your settings.
