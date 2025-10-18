# My dotfiles

## Windows settings

### Kanata

For [kanata](https://github.com/jtroo/kanata), add [this script](../dotfiles/setup/windows/launch_kanata.bat) to be run at startup.

### GlazeWM

For [glazewm](https://github.com/glzr-io/glazewm), add [this script](../dotfiles/setup/windows/launch_glazewm.bat) to be run at startup.
Adding some features to the config, such as automoving the browser tabs to the appropriate workspace, makes the os buggy...

### Keyboard layout

Easily cycle between keyboard layouts using Windows key + space. Deactivate in the settings to binding that uses Tab + Shift to achieve the same goal since it conflicts with i3 bindings.

### Windows terminal

Install [Windows Terminal](https://github.com/microsoft/terminal) and set the good [settings](../dotfiles/.config/windows_terminal/settings.json).

### Misc

In the apps that launch at startup, add at least kanata and GlazeWM. To do so, press Win + R to open the Run dialog, and type shell:startup.
Set the language to English. Set the dark mode. Set the bar to be hidden.
Install VSCode, Chrome.

## Linux settings

### General

Run the [installation script](../dotfiles/setup/install.sh).

### Kanata

Follow [this guide](https://github.com/jtroo/kanata/discussions/130).

I didn't want to fight with permissions and all that stuff, so I made a system-wide config (/lib/systemd/system/kanata.service) without the (it looks like) useless Environment entries:

```bash
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=/home/user/.cargo/bin/kanata --cfg /home/user/.config/kanata/config-name.kbd
Restart=never

[Install]
WantedBy=default.target
```

Also:

```bash
# sudo systemctl daemon-reload # maybe this will be required when changing the service file
sudo systemctl start kanata
sudo systemctl enable kanata
```

## Misc

Install VSCode, Chrome.

## Mac settings

### Kanata

```bash
brew install kanata
```

To automatically launch Kanata at system startup, you need to create two .plist files and place them in /Library/LaunchDaemons/.

The first one starts the Karabiner driver.
The second one launches Kanata with your custom configuration.

For `org.custom.karabiner.plist`:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.custom.karabiner</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

For `org.custom.kanata.plist`:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.custom.kanata</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/kanata</string>
        <string>--cfg</string>     <string>YOUR_KBD_FILE_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

```bash
sudo launchctl load /Library/LaunchDaemons/org.custom.karabiner.plist
sudo launchctl load /Library/LaunchDaemons/org.custom.kanata.plist
```

In case you need to stop Kanata from running via launchctl:

```bash
sudo launchctl unload /Library/LaunchDaemons/org.custom.kanata.plist
```
