# polybar-module-vpn

Manage your VPN via this polybar module. The module reports the VPN's status in one of three states: `[<ip_address> | connecting... | No VPN ]`, where the IP address is your public IP given after connecting to Mullvad. With optional dependencies, `<ip_address>` will be replaced with `<city> <country>`.
- left-click to connect and disconnect
- right-click to access an optional rofi menu and select between your favorite locations as well as 35 countries
- middle-click to copy your public IP address to the clipboard


### vpn support
**The stock settings are intended for use with [Mullvad VPN](https://mullvad.net).**

The module is scripted to facilitate other VPN's, but compatibility will depend on your VPN's API. See the `vpn_module.sh` script user settings to judge whether this code can easily be adapted for your choice of VPN.

It'd be great to make this module more robust for other VPN's, so please contribute other setups. Thanks!


![](vpn-module-demo.gif)

###### (The polybar theme seen in the gif was modified from polybar-5 provided by [Aditya Shakya](https://github.com/adi1090x/polybar-themes) and originally designed by [Benedikt Vollmerhaus](https://gitlab.com/BVollmerhaus))

## dependencies (assuming Mullvad VPN):
- `mullvad-vpn` (or `mullvad-vpn-cli`)

Mullvad is available in the [AUR](https://aur.archlinux.org/packages/mullvad-vpn/). Use your own VPN otherwise and see configuration for setup details.

### optional dependencies:
- `rofi` 				  - allows menu-based control of the VPN
- `geoip` and `geoip-database` - together provide country info instead of public address
- `geoip-database-extra`  - also provides city info
- `xclip`                 - allows copying ip address to clipboard

The optional dependencies can be found in the [Arch Package Repository](https://www.archlinux.org/packages/).

## configuration

### polybar module

This setup assumes that your `polybar` configuration is at `~/.config/polybar`.

```
[module/vpn]
type = custom/script
exec = $HOME/.config/polybar/scripts/vpn_module.sh
click-left = $HOME/.config/polybar/scripts/vpn_module.sh --toggle-connection &
click-right = $HOME/.config/polybar/scripts/vpn_module.sh --location-menu &
click-middle = $HOME/.config/polybar/scripts/vpn_module.sh --ip_address &
interval = 5
format =  <label>
format-background = ${color.mb}
```

### install

To setup a VPN other than Mullvad, read the configuration tips in `vpn_module.sh`. Modify as necessary.

```
git clone https://github.com/shervinsahba/polybar-module-vpn.git
cd polybar-module-vpn
cp fonts/* $HOME/.local/share/fonts/
cp vpn_module.sh $HOME/.config/polybar/scripts/
cat vpn_user_module >> $HOME/.config/polybar/user_modules.ini
```
After installation add `vpn` to your `config.ini` modules.