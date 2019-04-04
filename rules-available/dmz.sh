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

## Zwingend einzutragen
## Eintrag sollte unique sein!
rulename="DMZ"

## nicht verändern
## Diese beiden Zeilen erzeugen ein Array, welches in der "ende.sh" eingelesen und
## und entsprechend verarbeitet wird.
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
## Container"$rulename" definieren
$FW -N $rulename
########################################################
## Angabe ob das Regelset für ein Netzwerk zuständig sein soll oder nur für einen Host
## Wird diese Variable nicht gesetzt oder ist nicht vorhanden, wird das Script
## zwar ordentlich funktionieren, das Logging aber wird nicht korrekt angezeigt,
## da die Firewall sonst nicht nach den einzelnen Netzwerken unterscheiden kann
## Zudem wird "current_object_s" für das definieren der Rückrouten benötigt,
## damit der Router weiß, wohin die Antwortpakete gesendet werden dürfen.
## "current_object_d" kann jedoch leer bleiben.
######
## Source Host or Net
current_object_s[$count]="172.16.16.0/24"
## Destination Host or Net
current_object_d[$count]="0.0.0.0/0"
########################################################


$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -p udp -m multiport --dport 123 -j ACCEPT		# NTP fürs Netz zulassen nach ntp.home

## Webserver DMZ
## Kommunikation in diese Richtungen zulassen
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.50 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.50 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.50 -j ACCEPT

## Telefonanlage DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.57 -p udp -m multiport --dport 5060 -j ACCEPT		# SIP-Provider
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.11  -j ACCEPT		# DNS
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.2  -j ACCEPT		# Zugriff PC Webconsole
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.104 -j ACCEPT		# Mobiltelefon


$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -d 172.16.16.71 -j ACCEPT		## gitlab2.home
$FW -A $rulename -o $DEV_INTERN -i $DEV_DMZ1 -s 172.16.16.71 -j ACCEPT		## gitlab2.home
