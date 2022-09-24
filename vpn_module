#!/bin/bash

## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## vpn_module: vpn scripts for polybar
## 	by Shervin S. (shervin@enchanter.ai)


##  vpn_module: allows monitoring of VPN status and location, as well as set a new location via a Rofi menu.
##  The stock setup was designed with Mullvad VPN in mind, though the code
##  was left somewhat generic to extend usage to other VPNs.

##	dependencies:
##		mullvad-vpn           - this script assumes you use Mullvad, but may work for others with slight changes
##		rofi				  - allows menu based control

##	optional dependencies:
##		geoip, geoip-database - These can be used to lookup country location info.
##      geoip-database-extra  - In conjunction with above, can provide city info.
##		curl				  - allows accessing online API to lookup public ip
##      xclip                 - allows copying ip address to clipboard

## polybar setup:
## - Append contents of the polybar_module_definition file to modules.ini or user_modules.ini
## - Add "vpn" module to your config.ini under modules
## Interact with the module via left-clicks to toggle VPN, middle-click to copy your IP, and right-click     to get a menu.


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## User Settings

## [Set VPN commands]. Setup for Mullvad is done below.
# The first three commands should have direct equivalents for most VPNs.
# The relay_set command assumes <country_code> <city_code> will follow as arguments. See below.
VPN_CONNECT="mullvad connect"
VPN_DISCONNECT="mullvad disconnect"
VPN_GET_STATUS="mullvad status"
VPN_RELAY_SET_LOCATION="mullvad relay set location"

## [Set VPN status parsing]
# The first command cuts the status, which is compared to keywords below.
# It's made to be fairly generic to apply across VPNs.
VPN_STATUS="$($VPN_GET_STATUS | grep -Eio 'connected|connecting|disconnected' \
	| tr '[:upper:]' '[:lower:]')"
CONNECTED="connected"
CONNECTING="connecting"

## [Set colors] (set each variable to nothing for default color)
# Icons glyphs should be given by most Nerd Fonts (https://www.nerdfonts.com/cheat-sheet)
ICON_CONNECTED=""
ICON_CONNECTING="ﱱ"
ICON_DISCONNECTED=""
COLOR_CONNECTED="#a5fb8f"
COLOR_CONNECTING="#FAE3B0"
COLOR_DISCONNECTED="#f087bd"

## [Set rofi menu]. `man rofi` for help on location params.
#important: keep the icons to a single character for the rofi menu to work as intended
rofi_location="-location 3 -xoffset -530 -yoffset +30"
rofi_menu_name="ﱾ VPN"


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## Main Script

# Country codes, taken from `mullvad relay list`.
# They ought to connect to your VPN's choice of server in the region.
DIRNAME="$(dirname "$(realpath "$0")")"
mapfile -t VPN_LOCATIONS < "$DIRNAME"/mullvad/locations
mapfile -t VPN_CODES < "$DIRNAME"/mullvad/codes

ip_address_lookup() {
	ip_address=$($VPN_GET_STATUS | \
		awk 'match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/){print substr($0,RSTART,RLENGTH)}')
	if [ -z "$ip_address" ]; then
		ip_address=$(curl --silent https://icanhazip.com/)
	fi
	echo "$ip_address"
}

vpn_report() {
# reports connection status and location
	if [ "$VPN_STATUS" = "$CONNECTED"  ]; then
		if [ "$@" ]; then
			if [ "$1" == "mullvad" ]; then
			# use mullvad status to read location
				report="$($VPN_GET_STATUS | sed -n 's/.*in //p')"

			elif [ "$1" == "other-vpn" ]; then
			# use a generic check to see if VPN provides location in its status command.
				country=$($VPN_GET_STATUS | awk 'tolower ($0) ~ /country/{print $2}')
				city=$($VPN_GET_STATUS | awk 'tolower ($0) ~ /city/{print $2}')
				report="$city $country"

			elif [ "$1" == "geoip" ] && hash geoiplookup 2>/dev/null; then
			# use the geoip package to lookup location
				ip_address=$(ip_address_lookup)
				country=$(geoiplookup "$ip_address" | head -n1 | cut -c24-25)
				city=$(geoiplookup "$ip_address" | cut -d',' -f5 | sed -n '2{p;q}' | sed 's/^ //')
				report="$city $country"

			elif [ "$1" == "ip" ]; then
			# just print your public ip address, not a location
				report=$(ip_address_lookup)
			fi

			echo "%{F$COLOR_CONNECTED}$ICON_CONNECTED $report%{F-}"

		else
			echo "You need to provide a status method."
		fi		

	elif [ "$VPN_STATUS" = "$CONNECTING" ]; then
		echo "%{F$COLOR_CONNECTING}$ICON_CONNECTING Connecting...%{F-}"

	else
		echo "%{F$COLOR_DISCONNECTED}$ICON_DISCONNECTED No VPN%{F-}"
	fi
}


vpn_toggle_connection() {
# connects or disconnects vpn
    if [ "$VPN_STATUS" = "$CONNECTED" ]; then
        $VPN_DISCONNECT
    else
        $VPN_CONNECT
    fi
}


vpn_location_menu() {
# Allows control of VPN via rofi menu. Selects from VPN_LOCATIONS.
	if hash rofi 2>/dev/null; then
		## shellcheck throws errors here, but the globbing of $rofi_location is intentional
		# shellcheck disable=SC2086
		MENU="$(rofi $rofi_location -sep "\n" -dmenu -i -p "$rofi_menu_name" -input "$DIRNAME"/mullvad/menu)"

		case "$MENU" in
			*connect) 
				vpn_toggle_connection
				return
			;;
			
			*)
				## shellcheck throws errors here, but the globbing of $VPN_RELAY_SET_LOCATION is intentional
				# shellcheck disable=SC2086
				for i in "${!VPN_LOCATIONS[@]}"; do
					if [ "${MENU}" = "${VPN_LOCATIONS[$i]}" ]; then
						$VPN_RELAY_SET_LOCATION ${VPN_CODES[$i]};
					fi
				done

				if [ "$VPN_STATUS" = "$CONNECTED" ]; then
	        		return
	    		else
	        		$VPN_CONNECT
	    		fi
			;;
		esac
	fi
}


ip_address_to_clipboard() {
# finds your IP and copies to clipboard
	ip_address_lookup | xclip -selection clipboard
}


case "$1" in
	toggle|--toggle-connection) vpn_toggle_connection ;;
	menu|--location-menu) vpn_location_menu ;;
	ip-clip|--ip-address) ip_address_to_clipboard ;;
	status) vpn_report "$2" ;;
	help|*) cat <<- EOF

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
	EOF
esac
