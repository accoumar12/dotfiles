# My dotfiles

## Windows settings

For [kanata](https://github.com/jtroo/kanata), add a command to be run at startup:

```powershell
C:\Windows\System32\conhost.exe `
--headless "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\kanata\kanata.exe" `
--cfg "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\kanata\kanata.kbd"
```

For [glazewm](https://github.com/glzr-io/glazewm), also add a startup shortcut:

```powershell
"C:\Program Files\glzr.io\GlazeWM\glazewm.exe" start `  
--config="C:\Users\maccou\Desktop\GlazeWM\config.yaml"
```

Adding some features to the config, such as automoving the browser tabs to the appropriate workspace, makes the os buggy...

In the apps that launch at startup, add at least kanata and GlazeWM.

## Linux settings

For kanata, follow [this guide](https://github.com/jtroo/kanata/discussions/130)
