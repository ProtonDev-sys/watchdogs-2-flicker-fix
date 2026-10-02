# Watch Dogs 2 Flicker Fix

A one-click installer for [Luma](https://github.com/Filoppi/Luma-Framework)'s Watch Dogs 2 mod, which fixes the shadow flickering on modern GPUs (tested on an RTX 5070).

The fix itself is Luma's work (Pumbo + Miru). This repo just downloads the official release, checks it, and installs it. Online play works.

## Install

1. [Download the ZIP](https://github.com/ProtonDev-sys/watchdogs-2-flicker-fix/releases/latest/download/Watch-Dogs-2-Flicker-Fix-Setup.zip) and extract it.
2. Close the game and run `Install.cmd`.
3. Pick your Watch Dogs 2 folder, e.g. `D:\SteamLibrary\steamapps\common\Watch_Dogs2`.
   In Steam: right-click the game > Properties > Installed Files > Browse.

Press **F10** in-game to open the Luma/ReShade menu.

## What it does

- Downloads Luma [`latest-722`](https://github.com/Filoppi/Luma-Framework/releases/tag/latest-722) (~36 MB) from GitHub and checks its SHA-256.
- Copies the mod files into `bin\` next to `WatchDogs2.exe`. It stops if any of them already exist, so it won't overwrite another mod.
- Sets the overlay key to F10 and turns off Luma's super resolution, which avoids the DLSS popup.

This is the full Luma mod, so you also get HDR and its other rendering changes. Nothing else is touched: game files, saves and drivers are left alone.

## Uninstall

Close the game, run `Uninstall.cmd` and pick the same folder. It removes the files it installed and restores your old `ReShade.ini`. Any mod file you've edited since installing is left in place. Backups stay in `bin\WD2-Luma-Installer-Backup`.

To reinstall later, move or delete that backup folder first.

## Troubleshooting

- **Can't find WatchDogs2.exe**: you picked the wrong folder. Pick the install folder, not Documents\My Games.
- **Existing mod file**: you already have ReShade or another mod installed. Remove it first.
- **Backup already exists**: run `Uninstall.cmd`, then move the backup folder out.
- **Access denied**: the game is in a protected folder like Program Files. Run `Install.cmd` as administrator.
- **Checksum mismatch**: the download didn't match the expected file, so nothing was installed. Open an issue.

## Command line

```powershell
.\Setup.ps1 -GameDirectory 'D:\SteamLibrary\steamapps\common\Watch_Dogs2'
.\Setup.ps1 -GameDirectory '...' -Uninstall
.\Setup.ps1 -GameDirectory '...' -ArchivePath .\Luma-Watch_Dogs_2.zip   # use an already downloaded zip
```

`Build.ps1` creates the release ZIP and `SHA256SUMS.txt` in `artifacts\`.

Pinned upstream SHA-256: `35c3e100f909fab9d0a975a57bbdf46b6f6bf6c9268d5385c1e449f8aaacfa48`

## License

The installer scripts are MIT. Luma's own license applies to Luma. This project isn't affiliated with Ubisoft or Luma.
