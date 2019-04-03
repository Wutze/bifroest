#!/usr/bin/env bash
#
# Simple Firewall-Script with iptables
# only IPv4
#
# (c) by Wutze 2006-18 Version 3.0
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.
# Version 1.x
#
# Twitter -> @HuWutze
# Repo: home
#cd /opt/firewall

## Debug your Script
## Start this Script with: DEBUG=1 ./firewall.sh [Options]
test -z "$DEBUG" || set -x

### Start Firewall!
NAME="Firewall"
PIDFILE=/var/run/$NAME.pid
LOGFW=1

# many thanks to the pi-hole project for the next 5 color-lines
# print status, run in color
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"


# Zeige Status
# für Ok
# print_out 1 "Statusmeldung"
# für Fehler
# print_out 0 "Statusmeldung"
print_out(){
	case "${1}" in
		1)
		echo -e " ${TICK} ${2}"
		;;
		0)
		echo -e " ${CROSS} ${2}"
		;;
	esac
}

hilfe() {
	echo "#######################################################################"
	echo "# firewall start - Firewall initialisieren/starten"
	echo "# firewall stop - Firewall stoppen"
        echo "# firewall reload/restart - Firewall neu starten (legt automatisch ein Backup an)"
	echo "# firewall save - Backup der Firewall nach /tmp/"
	echo "# firewall restore - Backup der Firewall einspielen und aktivieren"
	echo "# firewall logon - Logging stoppen (/var/log/syslog)"
	echo "# firewall logoff - Logging starten (/var/log/syslog)"
	echo "#"
	echo -e "#${COL_LIGHT_GREEN} Zusatzoptionen zu den Sicherungsfunktionen ${COL_NC}"
	echo "# firewall autorestore on - Automatischen Restore aktivieren"
	echo "# firewall autorestore off - Automatischen Restore deaktivieren"
	echo "# firewall check - Firewall, ohne sie zu starten, testen"
	echo "# firewall enable \"rulename\" - Container enable"
	echo "# firewall disable \"rulename\" - Container disable"
        echo "#"
        echo -e "#${COL_LIGHT_RED} use \"DEBUG=1 firewall [option]\" - enable script debugging ${COL_NC}"
	echo "#######################################################################"

}

## Einlesen der Variablen
## Hier werden alle Variablen angegeben, die für das vollständige Script benötigt werden.
read_vars(){
	source firewall.conf
}

disable_fw(){
	## reset iptables
	$FW -F
	$FW -X
	$FW -t nat -F
	$FW -t nat -X
	$FW -t mangle -F
	$FW -t mangle -X
	$FW -P INPUT ACCEPT
	$FW -P FORWARD ACCEPT
	$FW -P OUTPUT ACCEPT
}

save(){
	iptables-save > /tmp/ipt.backup
}

restore(){
	iptables-restore < /tmp/ipt.backup
}

start_fw() {
	# Firwall wird vorbereitet
	# als erstes alle Regeln loeschen
	# danach die Firewall neu aufbauen
	# Initialisierung der Firewall mit dem Standard-Regeln
	source main/init.sh
	
	# Nun alle zusätzlichen Regeln einlesen
	# Die Regeln sollten alle in rules-available/ 
	# Ein Sym-Link nach rules-enabled/ "schaltet" diese dann automatisch hinzu
	# einlesen der Regeln jetzt:
	source <(cat rules-enabled/*.sh) >&2

	# Konfiguration Firewall abschließen und alle Regeln in die Tabellen eintragen
	# Routungs aktivieren, Forwarding, Masquerade usw.
	# Wichtig!
	# In den einzelnen eigenen Transport-Regeln müssen diese beiden Zeilen vorhanden sein
	# count=$(( $count + 1 ))
	# forward-rule[$count]=$rolename
	# Mit Hilfe dieser beiden zeilen werden die Reglen voneinander getrennt im logging
	# unter /var/log/syslog dargestellt
	# Bitte die Doku beachten!
	source main/ende.sh

	# Script ist durch
}

main(){
	case "$main1" in
		start)
			read_vars
			start_fw
			echo 1 > $PIDFILE
			print_out 1 "Start $NAME"
			exit 0
			;;
		reload|restart)
			save
			read_vars
			disable_fw
			start_fw
			print_out 1 "Reload $NAME"
			exit 0
			;;
		stop)
			read_vars
			disable_fw
			print_out 1 "Stopping $NAME"
			rm $PIDFILE
			exit 0
			;;
		help|hilfe)
			hilfe
			exit 0
			;;
		save)
			save
			print_out 1 "$NAME Backup saved"
			exit 0
			;;
		restore)
			read_vars
			disable_fw
			restore
			print_out 1 "$NAME Backup restored"
			exit 0
			;;
		autorestore)
			print_out 0 "No Funktion at the moment"
			exit 0
			;;
		enable|disable)
			print_out 0 "No Funktion at the moment"
			exit 0
			;;
		status)
			if [[ -f "${PIDFILE}" ]]; then
				print_out 1 "$NAME running "
			else
				print_out 0 "$NAME not running"
			fi
			exit 0
			;;
		logon)
			LOGFW=1
			read_vars
			disable_fw
			start_fw
			exit 0
			;;
		logoff)
			LOGFW=0
			read_vars
			disable_fw
			start_fw
			exit 0
			;;
		*)
			echo "Usage: $main0 {start|stop|logon|logoff|reload|status|help|save|restore|autorestore [on/off]|check|enable/disable [rulename]}" >&2
			exit 3
			;;
	esac
}

## WOL aktivieren auf dem lokalen Host
#echo -n NMAC | tee /proc/acpi/wakeup

main0=$0
main1=$1
main2=$2

main


# Notitzen
# iptables -L -nv --line-numbers
