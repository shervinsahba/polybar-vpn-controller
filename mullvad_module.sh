#!/bin/bash


## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

## mullvad_module: mullvad scripts for a polybar.
## 	by Shervin S. (shervin@tuta.io)

## 	mullvad_module reports mullvad's status as [<ip_address> | connecting... | No VPN ].
##  With optional dependencies, <ip_address> will be replaced with <city> <country>.
##  You can also connect and disconnect via left-clicks, or with rofi, right-click to
##  access a menu and select between your favorite locations, set in VPN_LOCATIONS,
##  as well as 35 countries.

##	dependencies:
##		mullvad-vpn (or mullvad-vpn-cli)

##	optional dependencies: 
##		rofi 				  - allows menu-based control of mullvad
##		geoip, geoip-database - provide country info instead of public address
## 		geoip-database-extra  - also provides city info


## For use with polybar, use a module script in user_modules.ini like so:
##
## [module/mullvad]
## type = custom/script
## exec = $HOME/.config/polybar/scripts/mullvad_module.sh
## click-left = $HOME/.config/polybar/scripts/mullvad_module.sh --toggle-connection &
## click-right = $HOME/.config/polybar/scripts/mullvad_module.sh --location-menu &
## interval = 5
## format =  <label>
## format-background = ${color.mb}

## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# Hint: Set your 8 favorite vpn locations here. These will
# be passed to mullvad as `mullvad relay set location <input>`.
VPN_LOCATIONS=("us sea" "us chi" "us nyc" "us" "jp" "au" "fr" "br")


# These are country codes taken from `mullvad relay list`. 
# They ought to connect to mullvad's choice of VPN in the region.
COUNTRIES=("Albania (al)" "Australia (au)" "Austria (at)" "Belgium (be)" "Brazil (br)" "Bulgaria (bg)" "Canada (ca)" "Czech Republic (cz)" "Denmark (dk)" "Finland (fi)" "France (fr)" "Germany (de)" "Greece (gr)" "Hong Kong (hk)" "Hungary (hu)" "Ireland (ie)" "Israel (il)" "Italy (it)" "Japan (jp)" "Latvia (lv)" "Luxembourg (lu)" "Moldova (md)" "Netherlands (nl)" "New Zealand (nz)" "Norway (no)" "Poland (pl)" "Romania (ro)" "Serbia (rs)" "Singapore (sg)" "Spain (es)" "Sweden (se)" "Switzerland (ch)" "UK (gb)" "United Arab Emirates (ae)" "USA (us)")
COUNTRY_CODES=("al" "au" "at" "be" "br" "bg" "ca" "cz" "dk" "fi" "fr" "de" "gr" "hk" "hu" "ie" "il" "it" "jp" "lv" "lu" "md" "nl" "nz" "no" "pl" "ro" "rs" "sg" "es" "se" "ch" "gb" "ae" "us")

# Concatenate arrays
VPN_CODES=$VPN_LOCATIONS
VPN_CODES+=("${COUNTRY_CODES[@]}")
VPN_LOCATIONS+=("${COUNTRIES[@]}")


mullvad_report(){
# continually reports connection status

	mullvad_status=$(mullvad status)
	ip_address=$(echo $mullvad_status | grep -oe [0-9].*: | cut -f1 -d:)

	if echo $mullvad_status | grep -q 'Connected'; then
		if hash geoiplookup 2>/dev/null; then
			country=$(geoiplookup $ip_address | grep "GeoIP Country" | cut -d' ' -f4 | cut -d, -f1)
			city=$(geoiplookup $ip_address | grep "GeoIP City" | cut -d, -f5 | sed 's/ //')
			echo "$city $country"
		else
			echo "$ip_address"
		fi
	elif echo $mullvad_status | grep -q 'Connecting'; then
		echo "connecting..."
	else
		echo "No VPN"
	fi
}


mullvad_toggle_connection() {
# connects or disconnects mullvad
    if echo $(mullvad status) | grep -q "Connected"; then
        mullvad disconnect
    else
        mullvad connect
    fi
}


mullvad_location_menu() {
# Allows control of mullvad via rofi menu. Selects from VPN_LOCATIONS.

	# Hints to tweak rofi below: 
	# - Set your desired font and theme.
	# - Change location and offsets depending on where you want the module.
	#   e.g. upper right: -location 3 -xoffset -50 -yoffset 50 
	#   e.g. lower right: -location 5 -xoffset -50 -yoffset -50 

	if hash rofi 2>/dev/null; then

		MENU="$(rofi -font 'Fire Code Retina 15' -theme solarized_alternate \
			-sep "|" -dmenu -i -p 'Mullvad VPN' -columns 1 -width 10 -hide-scrollbar \
			-location 5 -xoffset -50 -yoffset -50 \
			-line-padding 4 -padding 20 -lines 9 <<< \
			"  (dis)connect|  ${VPN_LOCATIONS[0]}|  ${VPN_LOCATIONS[1]}|  ${VPN_LOCATIONS[2]}|  ${VPN_LOCATIONS[3]}|  ${VPN_LOCATIONS[4]}|  ${VPN_LOCATIONS[5]}|  ${VPN_LOCATIONS[6]}|  ${VPN_LOCATIONS[7]}|  ${VPN_LOCATIONS[8]}|  ${VPN_LOCATIONS[9]}|  ${VPN_LOCATIONS[10]}|  ${VPN_LOCATIONS[11]}|  ${VPN_LOCATIONS[12]}|  ${VPN_LOCATIONS[13]}|  ${VPN_LOCATIONS[14]}|  ${VPN_LOCATIONS[15]}|  ${VPN_LOCATIONS[16]}|  ${VPN_LOCATIONS[17]}|  ${VPN_LOCATIONS[18]}|  ${VPN_LOCATIONS[19]}|  ${VPN_LOCATIONS[20]}|  ${VPN_LOCATIONS[21]}|  ${VPN_LOCATIONS[22]}|  ${VPN_LOCATIONS[23]}|  ${VPN_LOCATIONS[24]}|  ${VPN_LOCATIONS[25]}|  ${VPN_LOCATIONS[26]}|  ${VPN_LOCATIONS[27]}|  ${VPN_LOCATIONS[28]}|  ${VPN_LOCATIONS[29]}|  ${VPN_LOCATIONS[30]}|  ${VPN_LOCATIONS[31]}|  ${VPN_LOCATIONS[32]}|  ${VPN_LOCATIONS[33]}|  ${VPN_LOCATIONS[34]}|  ${VPN_LOCATIONS[35]}|  ${VPN_LOCATIONS[36]}|  ${VPN_LOCATIONS[37]}|  ${VPN_LOCATIONS[38]}|  ${VPN_LOCATIONS[39]}|  ${VPN_LOCATIONS[40]}|  ${VPN_LOCATIONS[41]}|  ${VPN_LOCATIONS[42]}|  ${VPN_LOCATIONS[43]}")"

	    case "$MENU" in
	    	*connect) mullvad_toggle_connection; break;;
			*"${VPN_LOCATIONS[1]}") mullvad relay set location ${VPN_CODES[1]};;
			*"${VPN_LOCATIONS[2]}") mullvad relay set location ${VPN_CODES[2]};;
			*"${VPN_LOCATIONS[3]}") mullvad relay set location ${VPN_CODES[3]};;
			*"${VPN_LOCATIONS[4]}") mullvad relay set location ${VPN_CODES[4]};;
			*"${VPN_LOCATIONS[5]}") mullvad relay set location ${VPN_CODES[5]};;
			*"${VPN_LOCATIONS[6]}") mullvad relay set location ${VPN_CODES[6]};;
			*"${VPN_LOCATIONS[7]}") mullvad relay set location ${VPN_CODES[7]};;
			*"${VPN_LOCATIONS[8]}") mullvad relay set location ${VPN_CODES[8]};;
			*"${VPN_LOCATIONS[9]}") mullvad relay set location ${VPN_CODES[9]};;
			*"${VPN_LOCATIONS[10]}") mullvad relay set location ${VPN_CODES[10]};;
			*"${VPN_LOCATIONS[11]}") mullvad relay set location ${VPN_CODES[11]};;
			*"${VPN_LOCATIONS[12]}") mullvad relay set location ${VPN_CODES[12]};;
			*"${VPN_LOCATIONS[13]}") mullvad relay set location ${VPN_CODES[13]};;
			*"${VPN_LOCATIONS[14]}") mullvad relay set location ${VPN_CODES[14]};;
			*"${VPN_LOCATIONS[15]}") mullvad relay set location ${VPN_CODES[15]};;
			*"${VPN_LOCATIONS[16]}") mullvad relay set location ${VPN_CODES[16]};;
			*"${VPN_LOCATIONS[17]}") mullvad relay set location ${VPN_CODES[17]};;
			*"${VPN_LOCATIONS[18]}") mullvad relay set location ${VPN_CODES[18]};;
			*"${VPN_LOCATIONS[19]}") mullvad relay set location ${VPN_CODES[19]};;
			*"${VPN_LOCATIONS[20]}") mullvad relay set location ${VPN_CODES[20]};;
			*"${VPN_LOCATIONS[21]}") mullvad relay set location ${VPN_CODES[21]};;
			*"${VPN_LOCATIONS[22]}") mullvad relay set location ${VPN_CODES[22]};;
			*"${VPN_LOCATIONS[23]}") mullvad relay set location ${VPN_CODES[23]};;
			*"${VPN_LOCATIONS[24]}") mullvad relay set location ${VPN_CODES[24]};;
			*"${VPN_LOCATIONS[25]}") mullvad relay set location ${VPN_CODES[25]};;
			*"${VPN_LOCATIONS[26]}") mullvad relay set location ${VPN_CODES[26]};;
			*"${VPN_LOCATIONS[27]}") mullvad relay set location ${VPN_CODES[27]};;
			*"${VPN_LOCATIONS[28]}") mullvad relay set location ${VPN_CODES[28]};;
			*"${VPN_LOCATIONS[29]}") mullvad relay set location ${VPN_CODES[29]};;
			*"${VPN_LOCATIONS[30]}") mullvad relay set location ${VPN_CODES[30]};;
			*"${VPN_LOCATIONS[31]}") mullvad relay set location ${VPN_CODES[31]};;
			*"${VPN_LOCATIONS[32]}") mullvad relay set location ${VPN_CODES[32]};;
			*"${VPN_LOCATIONS[33]}") mullvad relay set location ${VPN_CODES[33]};;
			*"${VPN_LOCATIONS[34]}") mullvad relay set location ${VPN_CODES[34]};;
			*"${VPN_LOCATIONS[35]}") mullvad relay set location ${VPN_CODES[35]};;
			*"${VPN_LOCATIONS[36]}") mullvad relay set location ${VPN_CODES[36]};;
			*"${VPN_LOCATIONS[37]}") mullvad relay set location ${VPN_CODES[37]};;
			*"${VPN_LOCATIONS[38]}") mullvad relay set location ${VPN_CODES[38]};;
			*"${VPN_LOCATIONS[39]}") mullvad relay set location ${VPN_CODES[39]};;
			*"${VPN_LOCATIONS[40]}") mullvad relay set location ${VPN_CODES[40]};;
			*"${VPN_LOCATIONS[41]}") mullvad relay set location ${VPN_CODES[41]};;
			*"${VPN_LOCATIONS[42]}") mullvad relay set location ${VPN_CODES[42]};;
			*"${VPN_LOCATIONS[43]}") mullvad relay set location ${VPN_CODES[43]};;
	    esac

	    if echo $(mullvad status) | grep -q "Connected"; then
	        true
	    else
	        mullvad connect
	    fi
	fi
}


# cases for polybar user_module.ini
case "$1" in
    --toggle-connection) mullvad_toggle_connection ;;
	--location-menu) mullvad_location_menu ;;
	*) mullvad_report ;;
esac