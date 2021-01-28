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
#


# Dieser Scriptblock verarbeitet alle zuvor in der firewall.sh eingelesenen Daten
# aus den verlinkten Dateien aus -> rules-enabled
# ein und verarbeitet jetzt die im Script befindlichen Informationen


#############################################################
## Die vorher gesetzten Regeln aus allen TRANSPORT-Regeln  ##
## alles aus FORWARD loeschen, dann neue Regeln einuegen   ##
$FW -P FORWARD DROP

# Die Variable $forwardrule ist ein Array, die jetzt mit ihren Inhalten
# abgearbeitet wird Das Array wird in den Regeldateien gesetzt
for i in "${!forwardrule[@]}"
do
	## Wenn Variable leer ist, wird kein Netzwerk unter FORWARD angegeben
	## Das ist schlecht, da sonst das Logging "falsch" funktioniert
	## letztlich zuständig ob Netzwerk oder Host mit dem Regelset angesprochen werden soll
	## Source
	if [ -z ${current_object_s[i]} ];
	then
		var_s=""
	else
		var_s=" -s ${current_object_s[i]} "
		var_s2=" -d ${current_object_s[i]} "
	fi
	## Destination
	if [ -z ${current_object_d[i]} ];
	then
		var_d=""
	else
		var_d=" -d ${current_object_d[i]} "
	fi
	
	## Regelsets einfuegen und nach FORWARD aktivieren
	# FORWARD aus Subnetz nach Subnetz
	$FW -A FORWARD $var_s $var_d -j ${forwardrule[i]}
	$FW -A ${forwardrule[i]} -m state --state RELATED,ESTABLISHED -j ACCEPT
	$FW -A FORWARD $var_s2 -m state --state RELATED,ESTABLISHED -j ${forwardrule[i]}
	$FW -A ${forwardrule[i]} $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-"${forwardrule[i]}" "
	$FW -A ${forwardrule[i]} -j DROP
	## Variablen leeren, da sonst die vorhergehenden eingetragen würden, wenn im nachfolgenden
	## Script die Variablen leer bleiben.
	var_s=""
	var_s2=""
	var_d=""
done

## Flooding Regeln
$FW -A FORWARD -p tcp --syn -m limit --limit 1/s -j ACCEPT
$FW -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
$FW -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
# Mache mal NAT
$FW -t nat -A POSTROUTING -o $DEV_EXTERN -j MASQUERADE
## und alles was nicht mehr passt ab ins Log damit
$FW -A FORWARD $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-FWD-ACCESS "

## NAT setzen für IPv4
echo "1" >  /proc/sys/net/ipv4/ip_forward

## Statusmeldung nach /var/log/syslog
echo "Firewall online - Status="$DEFAULT_STATUS" Logging="$DEBUG_FW"" | logger -i -t [FW]
