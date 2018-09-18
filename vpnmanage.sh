#!/bin/bash
usage () {
	echo "Overview: vpnmanage script connects to an OpenVPN server running on a Amazon EC2
	instance.

	Usage: sudo ./vpnmanage.sh [command]

	Examples:
	 sudo ./vpnmanage.sh  --auto

	Options:
	  -h, --help			display help message and exit
	  --auto 				download and configure the client side of the 
	  		OpenVPN for auto connect on start
	  --kill 				kill openvpn process
	  --ssh 				ssh connect to server
	"
	exit 1
}

user="autoseg@18.228.147.160" # server-side user and ip 


# Manages commands
case $1 in
	--ssh )
		ssh $user
		;;
	--auto )
		scp "$user:~/client.ovpn" .
		sudo cp "client.ovpn" "/etc/openvpn/client.conf"
		sudo "/etc/init.d/openvpn" start
		echo Auto-connect to VPN successfully configured. VPN will be start on reboot.
		;;
	--kill )
		sudo killall openvpn
		;;
	* )
		usage
		;;
esac	