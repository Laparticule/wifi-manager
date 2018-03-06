#!/bin/bash

# You can use this script to connect to a chosen wifi network

#---------------------------------------------------------------------


    # CHECKING INTERFACE

# Returns a list of available WIFI cards
wifi_cards=$( iw dev | grep "Interface" | cut -d ' ' -f 2 )
card_number=$( iw dev | grep -c "Interface" )

# If there are multiple WIFI cards, the user has to choose among them
if [[ $card_number -ge 2 ]]; then
    chosen_card=$( printf "$wifi_cards" | rofi -p "Select your WIFI card:" -dmenu)
else
    chosen_card="$wifi_cards"
fi

# Displays an error if no card has been chosen
if [[ -z $chosen_card ]]; then
    notify-send "Err: process terminated"
fi

# Makes sure that the wireless device is up
ip link set $chosen_card up


    # CHECKING NETWORKS

# Returns a list of available wifi networks
available_networks=$( iwlist $chosen_card scan | grep "ESSID:" | cut -d '"' -f 2 )

# Checks connection status
connection_status=$( iw $chosen_card link )
if [[ $connection_status != "Not connected." ]]; then
    connection_status="Connected as $( iw $chosen_card link | grep "SSID" | cut -d ' ' -f 2 )"
fi

# Displays network menu
chosen_network="$( printf "$available_networks" | rofi -p "$connection_status" -dmenu )"

# Displays an error if no network has been chosen
if [[ -z $chosen_network ]]; then
    notify-send "Err: process terminated"
fi


    # CONNECTING TO A CHOSEN NETWORK

# Asks for the WIFI password
network_password=$( rofi -p "Password for $chosen_network: " -password -dmenu )

# Connects to the chosen network
killall wpa_supplicant
wpa_supplicant -B -i $chosen_card -c <(wpa_passphrase "$chosen_network" "$network_password") &

sleep 5

# Checks connection status
connection_status=$( iw $chosen_card link )
if [[ $connection_status == "Not connected." ]]; then
    notify-send "Not connected...."
else
    connection_status=$( iw $chosen_card link | grep "SSID" | cut -d ' ' -f 2 )
    notify-send "Connected to $connection_status"
fi

# Obtain IP address by DHCP
dhclient $chosen_card &


#----------------------------------------------------------------------
