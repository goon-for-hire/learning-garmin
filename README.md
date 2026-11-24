# ciq-learning

Companion code for the guide **Garmin Connect IQ from the Ground Up — fenix 8 Solar 51mm**
(https://claude.ai/artifact/XQuuDhS7GNV1VVRK6Cjrvt).

Every project here targets one device, `fenix8solar51mm`, needs Connect IQ API 5.0 or newer,
and builds with strict type checking (`project.typecheck = 3` in each `monkey.jungle`).
They were written against the Connect IQ SDK 9.3.0 documentation.

## Before you start

Work through Module 2 of the guide first. You need:

- the Connect IQ SDK 9.3.0 and the fenix 8 Solar 51mm device, from the SDK Manager
- VS Code with Garmin's **Monkey C** extension
- your own developer key, made with **Monkey C: Generate a Developer Key** and kept in `~/.garmin/`

**Monkey C: Verify Installation** should pass before you open anything here.

## Opening a project

Open one project at a time, never the whole repo:

1. **File → Open Folder** and pick the folder that contains `manifest.xml`, for example `hello-fenix/`.
2. Start the simulator (`ciqsim`), then press **Ctrl+F5** (Run → Run Without Debugging).
   Choose Monkey C if VS Code asks, then `fenix8solar51mm`.
3. For unit tests, run **Monkey C: Run Tests** from the command palette.
4. To try it on the watch, run **Monkey C: Build for Device**, then copy the `.prg` file
   into `GARMIN/APPS` (Module 2, section 2.8).

## What's in each folder

| Folder | Type | Module | What it's for |
|---|---|---|---|
| `hello-fenix/` | watch app | 3 | Your first app: the files of a project, the lifecycle, a button press |
| `koans/` | watch app (tests) | 4 | 29 Monkey C koans. Each one is a unit test with a `FILL_ME_IN` blank to fill |
| `koans-solutions/` | watch app (tests) | 4 | The same koans, answered. Look only after ten honest minutes |
| `playground/` | watch app | 5 | Drawing: the 64-colour palette, clock geometry, a progress ring, fonts |
| `meridian/` | watch face | 6 | Sleep and partial updates, a heart-rate complication, settings, a Swedish translation |
| `zonering/` | data field | 7 | A heart-rate zone gauge that fits any slot, FIT contributions, unit tests |
| `setlog-step1/` | watch app | 8–9 | SetLog as it stands at the end of Module 9: the state machine, menus, pickers |
| `setlog/` | watch app | 8–13 | The finished capstone: recording, storage, settings, glance, background service, export |
| `tools/` | Python | – | Scripts that generated the launcher icons and the two koans projects |

`setlog-step1/` and `setlog/` are complete projects with different app ids, so both can be
installed at once. To see what a later module changed in one file, select the two versions in
VS Code's Explorer and choose **Compare Selected**.

## Starting your own app from one of these

Copy the folder, then give the copy a new app id in `manifest.xml` (Module 3 shows how).
Two apps with the same id share their storage and settings, which makes for confusing bugs.

## Keys and build output

No developer key is included, and none should ever be added. `.gitignore` keeps `*.der`,
`*.pem`, `bin/`, `*.prg`, `*.prg.debug.xml` and `*.iq` out of git. Treat your key like an SSH
private key: keep an encrypted backup, because every update to a published app has to be
signed with the same key.

## The tools

- `python3 tools/make_icon.py <out.png> <letter> <hex colour>` draws a 70×70 launcher icon
  (needs Pillow). Example: `python3 tools/make_icon.py icon.png S FF5500`.
- `python3 tools/build_koans.py` regenerates `koans/` and `koans-solutions/` from
  `tools/koans-master/`. **It overwrites your answers in `koans/`**, so commit or copy them first.

## A note on accuracy

This code was written against the SDK 9.3.0 documentation and checked carefully, but it
couldn't be compiled where it was written. If the compiler disagrees with it, the compiler is
right. Appendix D of the guide lists the common errors and their fixes.
