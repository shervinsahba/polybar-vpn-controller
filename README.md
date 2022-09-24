# polybar-vpn-controller

Manage your VPN via this module. The `vpn_module` reports the VPN's status in one of three states: `[<location> | Connecting... | No VPN ]`, where the location is your <city> <country> or public IP address. It also provides the ability to toggle the VPN connection, open a rofi menu with VPN locations to set, and copy your public ip to the clipboard.

The `polybar_module_definition` file can be appended to your polybar module definitions, adding the `vpn` module with these preset capabilities:
- left-click: connect and disconnect VPN
- right-click: open rofi menu to select between locations
- middle-click: copy your public IP address to the clipboard

![](vpn-module-demo.gif)

###### (Note: This gif is from an older version. The polybar theme seen in the gif was modified from polybar-5 provided by [Aditya Shakya](https://github.com/adi1090x/polybar-themes) and originally designed by [Benedikt Vollmerhaus](https://gitlab.com/BVollmerhaus))

## changelog
2022-09-24 Reimplemented favorite VPN location arrays.
 - You can once again set favorite VPN locations. Edit the `./mullvad/update_mullvad_relays` script, and look for the user favorite arrays.
  
2022-09-23 Overhauled the package...
 - Renamed  utility from `vpn_module.sh` to the more modern `vpn_module`. Several command calls have changed. See the usage section below or run `vpn_module help`. You can probably just re-clone the package and re-copy the new `polybar_module_definition`. The previous version is left under the branch `old-master`.
 - Added city level VPN locations! You can now select ANY of mullvad's relays through the rofi menu!
 - Replaced all the hard-coded VPN locations and rofi menu scripting with more extensible, dynamic scripting. The script now relies on a the mullvad directory, which contains VPN locations and their relay codes. Notably, the data files in this directory are all updated by running the `update_mullvad_relays` script.
 - Removed the favorite VPN array for now.
 - Removed the provided font, as it wasn't being used. Please use a Nerd Font if you'd like to match the contained glyphs or otherwise alter the icons for now.
 - Added a help menu that comes up when you run `vpn_module help` or the script with no parameters.

## supported VPNs
polybar-vpn-controller is scripted to facilitate differing VPN's, but compatibility will depend on your VPN's API. **The stock settings are intended for use with [Mullvad VPN](https://mullvad.net).** See the `vpn_module` script user settings to judge whether this code can easily be adapted for your choice of VPN. It'd be great to make this module more robust for other VPN's, so please contribute other setups. Thanks!

## dependencies
You need a VPN! 
- `mullvad-vpn`, available for Arch-baseds systems in the [AUR](https://aur.archlinux.org/packages/mullvad-vpn/)
- or another VPN (requires reconfiguring `vpn_module`)
- `rofi`, while not strictly necessary, is probably going to be wanted by the majority of users.
- a nerd font, if you want to use all the contained glyphs

### optional dependencies
- `geoip` and `geoip-database` - provide country info instead of public IP address
- `geoip-database-extra`  - also provides city info
- `xclip`                 - allows copying ip address to clipboard

The optional dependencies can be found in the [Arch Package Repository](https://www.archlinux.org/packages/).

## install

This setup assumes that you use Mullvad, that your `polybar` configuration is at `~/.config/polybar`, and that you are importing module definitions from `user_modules.ini`. (To setup a VPN other than Mullvad, read the configuration tips in `vpn_module`. Modify as necessary. Also change the status reporting method in `vpn_module` to either `geoip` or some other method. )

```
cd ~/.config/polybar
git clone https://github.com/shervinsahba/polybar-vpn-controller.git
cd polybar-vpn-controller
./mullvad/update_mullvad_relays
cat polybar_module_definition >> ~/.config/polybar/user_modules.ini
```

Now add the `vpn` module to your polybar's `config` or `config.ini`.

## usage
Run `vpn_module help`.
```
  Usage: vpn_module <option>

  options: 
    toggle           toggles VPN connection
    menu             opens rofi menu to select VPN location
    ip-clip          copies ip address to clipboard
    status <method>  reports back with VPN status and location

    methods:
       mullvad       uses mullvad status to print location
       other-vpn     uses a generic method to print location
       geoip         uses the geoip package to print location
       ip            prints ip address
```


## known issues

The Mullvad VPN client may create excessive entries in the system journal because of the way this script calls on it. To suppress these messages in your log, follow [these instructions](https://github.com/shervinsahba/polybar-vpn-controller/issues/6#issuecomment-669652829) for a distro with `systemd`. Tested on Manjaro and Arch.
