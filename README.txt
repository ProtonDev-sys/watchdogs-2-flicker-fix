WATCH DOGS 2 - LUMA FLICKER FIX SETUP

Extract the entire ZIP to a folder, close Watch Dogs 2, and double-click
Install.cmd. Select the Watch_Dogs2 installation folder or its bin folder.
Start the game normally afterwards. F10 opens/closes the ReShade/Luma menu.

Internet required: downloads the official Luma latest-722 WD2 release
(about 36 MB), the same version tested on the sender's RTX 5070.
Its SHA-256 is verified before installation. No game files, saves or personal
settings are included. No NVIDIA profile, driver, executable or anti-cheat changes.
Existing mod files cause installation to stop instead of overwriting them.
Existing ReShade.ini is backed up; only the overlay key and Luma super-resolution
setting are changed. DLSS is off to avoid the SMAA T2x / MSAA requirement popup.

This is the full Luma rendering mod, not a flicker-only patch; it also provides
HDR and other features. Upstream lists the WD2 mod as work in progress.
Start with single-player. Online / anti-cheat compatibility is not guaranteed.
Do not disable anti-cheat or security software to make it work.

UNDO: close the game, run Uninstall.cmd and select the same folder.
Only unchanged files installed by this tool are removed. Changed files are kept.
Original ReShade.ini is restored; newer settings are backed up separately.
Backups remain in bin\WD2-Luma-Installer-Backup. If installation stops partway,
run Uninstall.cmd to undo the files recorded before copying started.
Reinstall is deliberately blocked while that backup folder exists: retain it
elsewhere after uninstall before reinstalling. Game updates may require repair.

If access is denied in Program Files, run Install.cmd as administrator only
after reviewing these readable scripts. Windows policy may block unsigned scripts;
do not disable security protection. ExecutionPolicy Bypass is process-only,
not a permanent system setting. The installer does not request elevation itself.

Credits: Filoppi / Luma-Framework, Pumbo + Miru for Watch Dogs 2.
https://github.com/Filoppi/Luma-Framework
https://github.com/Filoppi/Luma-Framework/wiki
Pinned official download (not repackaged binaries):
https://github.com/Filoppi/Luma-Framework/releases/download/latest-722/Luma-Watch_Dogs_2.zip
SHA-256: 35c3e100f909fab9d0a975a57bbdf46b6f6bf6c9268d5385c1e449f8aaacfa48

Unofficial convenience installer. Not affiliated with Ubisoft, NVIDIA or Luma.
Mod binaries are downloaded unmodified from their publisher.
