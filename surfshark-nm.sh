#!/bin/bash

# User settings
# Locations must be provided how they appear in the "list" command
LOCATIONS='us-nyc de-ber it-mil uk-lon'
PROTOCOL='udp'
# You can get the credentials from https://my.surfshark.com/vpn/manual-setup/main
USERNAME='UsernameHere'
PASSWORD='PasswordHere'

# Internal variables
TMP_OVPNS='/tmp/surfshark_ovpns'
OVPNS_URL='https://my.surfshark.com/vpn/api/v1/server/configurations'

# --- List the available locations ---
function list_locations {
	# Download the zip
	mkdir -p $TMP_OVPNS
	cd $TMP_OVPNS
	wget -q $OVPNS_URL -O ovpns.zip

	# Read the content and extract locations
	if [ $PROTOCOL == 'udp' ]
	then
		ovpns=$(unzip -l ovpns.zip | grep -E "[[:lower:]]{2}-[[:lower:]]{3}.prod.surfshark.com_udp.ovpn" | awk '{print $4}')
		ovpns=${ovpns//".prod.surfshark.com_udp.ovpn"/"\t"}
		echo -e "Available locations:\n" $ovpns
	elif [ $PROTOCOL == 'tcp' ]
	then
		ovpns=$(unzip -l ovpns.zip | grep -E "[[:lower:]]{2}-[[:lower:]]{3}.prod.surfshark.com_tcp.ovpn" | awk '{print $4}')
		ovpns=${ovpns//".prod.surfshark.com_tcp.ovpn"/"\t"}
		echo -e "Available locations:\n" $ovpns
	else
		echo "Incorrect protocol specified. Please choose either 'udp' or 'tcp'."
	fi

	# Clean up
	cd ..
	rm -r $TMP_OVPNS
}

# --- Updates the VPN connections for the selected locations ---
function update_connections {
	# Check for real credentials
	if [[ $USERNAME == 'UsernameHere' || $PASSWORD == 'PasswordHere' ]]
	then
		echo 'It seems that the credentials specified are still the default ones.'
		echo 'Please edit the script with your actual credentials from https://my.surfshark.com/vpn/manual-setup/main'
		exit 1
	fi

	# Remove the existing configurations for the chosen locations
	for loc in $LOCATIONS
	do
		nmcli connection delete $loc
	done

	# Download and unzip .ovpn configuration files
	mkdir -p $TMP_OVPNS
	cd $TMP_OVPNS
	wget -q $OVPNS_URL -O ovpns.zip
	unzip -q -o ovpns.zip

	# Rename each chosen file and add
	for loc in $LOCATIONS
	do
		mv "$loc.prod.surfshark.com_$PROTOCOL.ovpn" "$loc.ovpn"
		nmcli connection import type openvpn file "$loc.ovpn"
		nmcli connection modify $loc +vpn.data "username=$USERNAME" vpn.secrets password="$PASSWORD"
	done

	# Clean up
	cd ..
	rm -r $TMP_OVPNS
}

# --- Print help and usage ---
function print_help {
	echo "Usage: $0 COMMAND [OPTIONS]"
	echo ''
	echo 'COMMANDS'
	echo -e '\tlist\t\t\t\tList the available VPN locations'
	echo -e '\tupdate\t\t\t\tDownload and add the chosen VPNs'
	echo -e '\thelp\t\t\t\tShow this help message'

	echo ''
	echo 'OPTIONS'
	echo -e '\tAt the moment, no additional options are supported.'
	echo -e '\tTo change the selected locations, chosen protocol, and VPN credential you must edit the script directly.'
}

# --- Parse the arguments and run ---
if [[ $1 == 'list' ]]
then
	list_locations
elif [[ $1 == 'update' ]]
then
	update_connections
elif [[ $1 == 'help' ]]
then
	print_help
else
	echo 'Unknown or invalid options.'
	echo ''
	print_help
fi