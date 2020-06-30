#!/bin/bash

## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## vpn_module: vpn scripts for a polybar, setup stock for Mullvad VPN
## 	by Shervin S. (shervin@tuta.io)

## 	vpn_module reports your VPN's status as [<ip_address> | connecting... | No VPN ].
##  With optional dependencies, <ip_address> will be replaced with <city> <country>.
##  You can also connect and disconnect via left-clicks, or with rofi, right-click to
##  access a menu and select between your favorite locations, set in VPN_LOCATIONS,
##  as well as 35 countries covered by Mullvad VPN.

##	dependencies (assuming use with Mullvad VPN):
##		mullvad-vpn (or mullvad-vpn-cli)

##	optional dependencies: 
##		rofi 				  - allows menu-based control of mullvad
##		geoip, geoip-database - provide country info instead of public address
## 		geoip-database-extra  - also provides city info


## For use with polybar, use a module script in user_modules.ini like so:
##
## [module/vpn]
## type = custom/script
## exec = $HOME/.config/polybar/scripts/vpn_module.sh
## click-left = $HOME/.config/polybar/scripts/vpn_module.sh --toggle-connection &
## click-right = $HOME/.config/polybar/scripts/vpn_module.sh --location-menu &
## interval = 5
## format =  <label>
## format-background = ${color.mb}


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## User Settings

# Set commands for your VPN. Setup for Mullvad as is.
VPNCOMMAND_CONNECT="mullvad connect"
VPNCOMMAND_DISCONNECT="mullvad disconnect"
VPNCOMMAND_STATUS="mullvad status"
VPNCOMMAND_RELAY_SET_LOCATION="mullvad relay set location"

# Set your 8 favorite vpn locations here. These will
# be passed to your VPN as `$VPNCOMMAND_RELAY_SET_LOCATION <input>`.
VPN_LOCATIONS=("us sea" "us chi" "us nyc" "us" "jp" "au" "fr" "br")

# Set style settings for optional rofi menu. `man rofi` for help.
icon_connect=
icon_fav=
icon_country=
rofi_font="Fira Code Retina 15"
rofi_theme="solarized_alternate"
rofi_location="-location 5 -xoffset -50 -yoffset -50"
rofi_menu_name="Mullvad VPN"

## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## Main Script

# These are country codes taken from `mullvad relay list`. 
# They ought to connect to Mullvad's choice of VPN in the region.
COUNTRIES=("Albania (al)" "Australia (au)" "Austria (at)" "Belgium (be)" "Brazil (br)" "Bulgaria (bg)" "Canada (ca)" "Czech Republic (cz)" "Denmark (dk)" "Finland (fi)" "France (fr)" "Germany (de)" "Greece (gr)" "Hong Kong (hk)" "Hungary (hu)" "Ireland (ie)" "Israel (il)" "Italy (it)" "Japan (jp)" "Latvia (lv)" "Luxembourg (lu)" "Moldova (md)" "Netherlands (nl)" "New Zealand (nz)" "Norway (no)" "Poland (pl)" "Romania (ro)" "Serbia (rs)" "Singapore (sg)" "Spain (es)" "Sweden (se)" "Switzerland (ch)" "UK (gb)" "United Arab Emirates (ae)" "USA (us)")
COUNTRY_CODES=("al" "au" "at" "be" "br" "bg" "ca" "cz" "dk" "fi" "fr" "de" "gr" "hk" "hu" "ie" "il" "it" "jp" "lv" "lu" "md" "nl" "nz" "no" "pl" "ro" "rs" "sg" "es" "se" "ch" "gb" "ae" "us")

# Concatenate arrays
VPN_CODES=("${VPN_LOCATIONS[@]}")
VPN_CODES+=("${COUNTRY_CODES[@]}")
VPN_LOCATIONS+=("${COUNTRIES[@]}")

# Grab VPN status
VPN_STATUS="$($VPNCOMMAND_STATUS | cut -d' ' -f3)"
CONNECTED=Connected   # TODO maybe change "Connected" for other VPNs
CONNECTING=Connecting # TODO maybe change "Connecting" for other VPNs

vpn_report() {
# continually reports connection status

	ip_address=$($VPNCOMMAND_STATUS | cut -d' ' -f7 | cut -d':' -f1)

	if [ "$VPN_STATUS" = "$CONNECTED"  ]; then  
		if hash geoiplookup 2>/dev/null; then
			country=$(geoiplookup "$ip_address" | head -n1 | cut -c24-25)
			city=$(geoiplookup "$ip_address" | cut -d',' -f5 | sed -n '2{p;q}' | sed 's/ //')
			echo "$city $country"
		else
			echo "$ip_address"
		fi
	elif [ "$VPN_STATUS" = "$CONNECTING" ]; then  
		echo "connecting..."
	else
		echo "No VPN"
	fi
}


vpn_toggle_connection() {
# connects or disconnects vpn
    if [ "$VPN_STATUS" = "$CONNECTED" ]; then
        $VPNCOMMAND_DISCONNECT
    else
        $VPNCOMMAND_CONNECT
    fi
}


vpn_location_menu() {
# Allows control of VPN via rofi menu. Selects from VPN_LOCATIONS.

	if hash rofi 2>/dev/null; then

		MENU="$(rofi \
			-font "$rofi_font" -theme $rofi_theme $rofi_location \
			-columns 1 -width 10 -hide-scrollbar \
			-line-padding 4 -padding 20 -lines 9 \
			-sep "|" -dmenu -i -p "$rofi_menu_name" <<< \
			" $icon_connect (dis)connect| $icon_fav ${VPN_LOCATIONS[0]}| $icon_fav ${VPN_LOCATIONS[1]}| $icon_fav ${VPN_LOCATIONS[2]}| $icon_fav ${VPN_LOCATIONS[3]}| $icon_fav ${VPN_LOCATIONS[4]}| $icon_fav ${VPN_LOCATIONS[5]}| $icon_fav ${VPN_LOCATIONS[6]}| $icon_fav ${VPN_LOCATIONS[7]}| $icon_country ${VPN_LOCATIONS[8]}| $icon_country ${VPN_LOCATIONS[9]}| $icon_country ${VPN_LOCATIONS[10]}| $icon_country ${VPN_LOCATIONS[11]}| $icon_country ${VPN_LOCATIONS[12]}| $icon_country ${VPN_LOCATIONS[13]}| $icon_country ${VPN_LOCATIONS[14]}| $icon_country ${VPN_LOCATIONS[15]}| $icon_country ${VPN_LOCATIONS[16]}| $icon_country ${VPN_LOCATIONS[17]}| $icon_country ${VPN_LOCATIONS[18]}| $icon_country ${VPN_LOCATIONS[19]}| $icon_country ${VPN_LOCATIONS[20]}| $icon_country ${VPN_LOCATIONS[21]}| $icon_country ${VPN_LOCATIONS[22]}| $icon_country ${VPN_LOCATIONS[23]}| $icon_country ${VPN_LOCATIONS[24]}| $icon_country ${VPN_LOCATIONS[25]}| $icon_country ${VPN_LOCATIONS[26]}| $icon_country ${VPN_LOCATIONS[27]}| $icon_country ${VPN_LOCATIONS[28]}| $icon_country ${VPN_LOCATIONS[29]}| $icon_country ${VPN_LOCATIONS[30]}| $icon_country ${VPN_LOCATIONS[31]}| $icon_country ${VPN_LOCATIONS[32]}| $icon_country ${VPN_LOCATIONS[33]}| $icon_country ${VPN_LOCATIONS[34]}| $icon_country ${VPN_LOCATIONS[35]}| $icon_country ${VPN_LOCATIONS[36]}| $icon_country ${VPN_LOCATIONS[37]}| $icon_country ${VPN_LOCATIONS[38]}| $icon_country ${VPN_LOCATIONS[39]}| $icon_country ${VPN_LOCATIONS[40]}| $icon_country ${VPN_LOCATIONS[41]}| $icon_country ${VPN_LOCATIONS[42]}| $icon_country ${VPN_LOCATIONS[43]}")"

	    case "$MENU" in
	    	*connect) vpn_toggle_connection; break;;
			*"${VPN_LOCATIONS[0]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[0]};;
			*"${VPN_LOCATIONS[1]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[1]};;
			*"${VPN_LOCATIONS[2]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[2]};;
			*"${VPN_LOCATIONS[3]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[3]};;
			*"${VPN_LOCATIONS[4]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[4]};;
			*"${VPN_LOCATIONS[5]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[5]};;
			*"${VPN_LOCATIONS[6]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[6]};;
			*"${VPN_LOCATIONS[7]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[7]};;
			*"${VPN_LOCATIONS[8]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[8]};;
			*"${VPN_LOCATIONS[9]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[9]};;
			*"${VPN_LOCATIONS[10]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[10]};;
			*"${VPN_LOCATIONS[11]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[11]};;
			*"${VPN_LOCATIONS[12]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[12]};;
			*"${VPN_LOCATIONS[13]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[13]};;
			*"${VPN_LOCATIONS[14]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[14]};;
			*"${VPN_LOCATIONS[15]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[15]};;
			*"${VPN_LOCATIONS[16]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[16]};;
			*"${VPN_LOCATIONS[17]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[17]};;
			*"${VPN_LOCATIONS[18]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[18]};;
			*"${VPN_LOCATIONS[19]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[19]};;
			*"${VPN_LOCATIONS[20]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[20]};;
			*"${VPN_LOCATIONS[21]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[21]};;
			*"${VPN_LOCATIONS[22]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[22]};;
			*"${VPN_LOCATIONS[23]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[23]};;
			*"${VPN_LOCATIONS[24]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[24]};;
			*"${VPN_LOCATIONS[25]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[25]};;
			*"${VPN_LOCATIONS[26]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[26]};;
			*"${VPN_LOCATIONS[27]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[27]};;
			*"${VPN_LOCATIONS[28]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[28]};;
			*"${VPN_LOCATIONS[29]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[29]};;
			*"${VPN_LOCATIONS[30]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[30]};;
			*"${VPN_LOCATIONS[31]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[31]};;
			*"${VPN_LOCATIONS[32]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[32]};;
			*"${VPN_LOCATIONS[33]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[33]};;
			*"${VPN_LOCATIONS[34]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[34]};;
			*"${VPN_LOCATIONS[35]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[35]};;
			*"${VPN_LOCATIONS[36]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[36]};;
			*"${VPN_LOCATIONS[37]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[37]};;
			*"${VPN_LOCATIONS[38]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[38]};;
			*"${VPN_LOCATIONS[39]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[39]};;
			*"${VPN_LOCATIONS[40]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[40]};;
			*"${VPN_LOCATIONS[41]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[41]};;
			*"${VPN_LOCATIONS[42]}") $VPNCOMMAND_RELAY_SET_LOCATION ${VPN_CODES[42]};;
	    esac

	    if [ "$VPN_STATUS" = "$CONNECTED" ]; then   # TODO maybe change "Connected" for other VPNs
	        true
	    else
	        $VPNCOMMAND_CONNECT
	    fi
	fi
}


# cases for polybar user_module.ini
case "$1" in
    --toggle-connection) vpn_toggle_connection ;;
	--location-menu) vpn_location_menu ;;
	*) vpn_report ;;
esac
