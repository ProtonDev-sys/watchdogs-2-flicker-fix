# Watch Dogs 2 Flicker Fix

An easy Windows installer for the **Luma Watch Dogs 2 rendering mod**, which includes a game-side shadow-flickering fix.

**The graphics fix is Luma's work, not a new patch developed by this repository.** This project makes a specific, checksum-verified Luma release easier to install and uninstall.

## Download and install

1. **[Download the installer ZIP](https://github.com/ProtonDev-sys/watchdogs-2-flicker-fix/releases/latest/download/Watch-Dogs-2-Flicker-Fix-Setup.zip).**
2. Right-click the ZIP and choose **Extract All**. Do not run it inside the ZIP.
3. Close **Watch Dogs 2**.
4. Double-click **Install.cmd** in the extracted folder.
5. Select your **Watch_Dogs2 installation folder**, or its **bin** folder.
6. Wait for **Installed and verified**, then start the game normally.

**F10 opens/closes the ReShade/Luma overlay. No Home key needed.**

Example Steam folder:

```text
D:\SteamLibrary\steamapps\common\Watch_Dogs2
```

In Steam, use **Library > Watch Dogs 2 > Properties > Installed Files > Browse** to find it. For another launcher, select the installation containing **bin/WatchDogs2.exe**, not your Documents/My Games save folder.

### Requirements

- Windows with Windows PowerShell 5.1.
- An installed PC copy of Watch Dogs 2.
- Internet access for the official mod download, about **36 MB**.
- Permission to write to the game folder.

The ZIP contains readable scripts, not mod binaries. The mod downloads directly from its publisher.

## What this installs

This installs the **full Luma rendering mod**, not an isolated flicker-only patch. It also includes HDR and other rendering features. Upstream lists its Watch Dogs 2 support as **work in progress**.

The installer:

- Downloads the pinned official **latest-722** Watch Dogs 2 package.
- Verifies its SHA-256 before installing anything.
- Copies and verifies the package's 49 files next to WatchDogs2.exe.
- Sets the overlay shortcut to **F10**.
- Disables **Luma super resolution** by default to avoid the DLSS anti-aliasing requirement popup. Game-side shader fixes remain enabled.
- Backs up an existing ReShade.ini, preserving settings except those two choices.
- Refuses to overwrite existing mod files and records its own files for uninstall.

It does **not** change the game executable, saves, NVIDIA profiles, drivers or anti-cheat settings.

The same upstream version was reported to resolve flickering on an RTX 5070 in the original setup. This does not guarantee a fix for every GPU, game build or flickering symptom.

## Uninstall

1. Close Watch Dogs 2.
2. Double-click **Uninstall.cmd**.
3. Select the same game folder.

Only recorded files that still match their installed hashes are removed. Modified files are **kept** and listed in the console.

Your original ReShade.ini is restored if one existed. Newer settings are backed up before restoration. If there was no original config, the generated one is removed after backing it up.

Backups remain in **bin/WD2-Luma-Installer-Backup**. Uninstall may leave empty mod folders or modified files; it does not recursively delete them.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| Close Watch Dogs 2 first | Fully exit the game and run again. |
| Cannot find WatchDogs2.exe | Select the actual installation folder or its bin folder, not the save folder. |
| Existing mod file | Review the existing ReShade/Luma/other mod setup. This installer will not overwrite it. |
| Backup already exists | Uninstall the previous setup first. Keep its backup somewhere safe before reinstalling. |
| Access denied | Check folder permissions. A protected installation may require running Install.cmd as administrator; inspect the scripts first. |
| Checksum mismatch | Installation stops before copying files. Do not remove the check; report the problem. |
| Installation stops partway | Run Uninstall.cmd to undo the recorded, unchanged files. Keep the backup. |
| Windows policy or security software blocks it | Review the source; do not disable security software or anti-cheat. |
| No overlay | Try F10 and consult upstream Luma documentation. Do not bypass anti-cheat restrictions. |

The CMD launchers use a **process-only** PowerShell execution-policy override, not a permanent system change. They do not automatically elevate or disable security software.

**Start with single-player.** This project has not verified online/anti-cheat compatibility. Other graphics mods and game updates can change compatibility. The installer does not bypass anti-cheat.

## Source and validation

- **Install.cmd**: double-click installation launcher.
- **Uninstall.cmd**: uninstall launcher.
- **Setup.ps1**: folder picker, verified download, installation and uninstall.
- **README.txt**: instructions included in the ZIP.
- **Build.ps1**: builds the shareable ZIP and SHA256SUMS.txt.

To build from source:

```powershell
powershell.exe -NoProfile -File .\Build.ps1
```

Output goes to **artifacts/**. No game files or personal settings are packaged.

Advanced usage from PowerShell:

```powershell
.\Setup.ps1 -GameDirectory 'D:\SteamLibrary\steamapps\common\Watch_Dogs2'
.\Setup.ps1 -GameDirectory 'D:\SteamLibrary\steamapps\common\Watch_Dogs2' -Uninstall
```

The optional **-ArchivePath** accepts a previously downloaded upstream ZIP. The exact same checksum verification still applies.

Validated: real upstream downloading, all 49 copied-file hashes, installation/uninstall in isolated fixture folders, configuration restoration, existing-mod refusal, and preservation of modified files. This is **not** automated in-game visual verification or online testing.

## Pinned upstream release

- [Release latest-722](https://github.com/Filoppi/Luma-Framework/releases/tag/latest-722)
- [Official Luma-Watch_Dogs_2.zip](https://github.com/Filoppi/Luma-Framework/releases/download/latest-722/Luma-Watch_Dogs_2.zip)
- SHA-256:

```text
35c3e100f909fab9d0a975a57bbdf46b6f6bf6c9268d5385c1e449f8aaacfa48
```

This is a deliberately pinned version, not a promise that it is always the newest release. Review upstream changes before updating the URL and checksum together.

## Credits and license

The rendering mod and graphics fix come from **[Luma-Framework](https://github.com/Filoppi/Luma-Framework)**. Upstream credits **Pumbo + Miru** for Watch Dogs 2. See the **[Luma wiki](https://github.com/Filoppi/Luma-Framework/wiki)** for features, status and support.

This repository's installer source is **MIT-licensed**. Downloaded third-party components retain their own upstream terms; this repository and ZIP do not redistribute those binaries.

An unofficial community installer, not affiliated with Ubisoft, NVIDIA, ReShade or Luma.
