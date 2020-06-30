# polybar-module-vpn

This polybar module reports the VPN's status in one of three states: `[<ip_address> | connecting... | No VPN ]`, where the IP address is your public IP given after connecting to Mullvad. With optional dependencies, `<ip_address>` will be replaced with `<city> <country>`. You can also connect and disconnect via left-clicks, or with rofi, right-click to access a menu and select between your favorite locations, set in VPN_LOCATIONS, as well as 35 countries.

**The stock settings are intended for use with [Mullvad VPN](https://mullvad.net).** The module is scripted to facilitate other VPN's, but compatibility will depend on your VPN's API. See the `vpn_module.sh` script user settings to judge whether this code can easily be adapted for your choice of VPN. Thanks!

![](mullvad-demo.gif)

###### (The polybar theme seen in the gif was modified from polybar-5 provided by [Aditya Shakya](https://github.com/adi1090x/polybar-themes) and originally designed by [Benedikt Vollmerhaus](https://gitlab.com/BVollmerhaus))

## dependencies (assuming Mullvad VPN):
- `mullvad-vpn` (or `mullvad-vpn-cli`)

Mullvad is available in the [AUR](https://aur.archlinux.org/packages/mullvad-vpn/). 

## optional dependencies: 
- `rofi` 				  - allows menu-based control of the VPN
- `geoip` and `geoip-database` - together provide country info instead of public address
- `geoip-database-extra`  - also provides city info

The optional dependencies can be found in the [Arch Package Repository](https://www.archlinux.org/packages/).

## polybar module

The `vpn_user_module` assumes that `polybar` is installed at `~/.config/polybar`. Modify as necessary.
```
[module/vpn]
type = custom/script
exec = $HOME/.config/polybar/scripts/vpn_module.sh
click-left = $HOME/.config/polybar/scripts/vpn_module.sh --toggle-connection &
click-right = $HOME/.config/polybar/scripts/vpn_module.sh --location-menu &
interval = 5
format =  <label>
format-background = ${color.mb}
```

## install

Please review the installation, and modify as needed prior to install.

```
git clone https://github.com/shervinsahba/polybar-module-vpn.git
cd polybar-module-vpn
cp fonts/* $HOME/.local/share/fonts/
cp vpn_module.sh $HOME/.config/polybar/scripts/
cat vpn_user_module >> $HOME/.config/polybar/user_modules.ini
