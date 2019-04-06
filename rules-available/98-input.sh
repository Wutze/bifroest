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

# Main-Rules for the Router
# The router is only supposed to transport packets (transport).
# Exceptions may be incoming (input) requests for ping,
# which it may also answer (output).
# Important! The firewall also blocks the communication to itself,
# i.e. localhost, and must therefore also be specified!

# Der Router soll eigentlich nur Pakete transportieren (Transport).
# Ausnahmen sind unter Umständen eingehende (Input) Anfragen
# nach Ping, die er auch beantworten darf (Output).
# Wichtig! Die Firewall blockiert auch die Kommunikation mich sich selbst,
# also localhost und muss demnach ebenfalls angegeben werden!

## Jeder Lokale Host darf mit sich selbst überall hin kommunizieren
$FW -A INPUT -i lo -j ACCEPT
## Auf einen Ping antworten darf das Ding auch
$FW -A INPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Anfragen aus den privaten Netzen, DMZ oder VPN erlauben
# Das beträfe http, https, ssh und alle weiteren Dienste, die auf dem Router unter Umständen laufen
# Alle wären aus den lokalen Netzen erreichbar
$FW -A INPUT -s $NET_INTERN -j ACCEPT
$FW -A INPUT -s $NET_LAN1 -j ACCEPT
$FW -A INPUT -s $NET_DMZ1 -j ACCEPT
$FW -A INPUT -s $NET_VPN0 -j ACCEPT

# Broadcast DHCP
$FW -A INPUT -i $DEV_INTERN -s 0.0.0.0 -d 255.255.255.255 -p udp -m multiport --dport 67 -j ACCEPT
$FW -A INPUT -i $DEV_LAN1 -s 0.0.0.0 -d 255.255.255.255 -p udp -m multiport --dport 67 -j ACCEPT
$FW -A INPUT -i $DEV_LAN2 -s 0.0.0.0 -d 255.255.255.255 -p udp -m multiport --dport 67 -j ACCEPT
$FW -A INPUT -i $DEV_LAN3 -s 0.0.0.0 -d 255.255.255.255 -p udp -m multiport --dport 67 -j ACCEPT
$FW -A INPUT -i $DEV_DMZ1 -s 0.0.0.0 -d 255.255.255.255 -p udp -m multiport --dport 67 -j ACCEPT

# Webserver erlauben
$FW -A INPUT -p tcp -i $DEV_EXTERN -m multiport --dport 80,443 -j ACCEPT	# Auf dem Router läuft ein Webserver, der darf Anfragen annehmen
### flooding/ddos blocken
$FW -I INPUT -p tcp --dport 443 -i $DEV_EXTERN -m state --state NEW -m recent --set
$FW -I INPUT -p tcp --dport 443 -i $DEV_EXTERN -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

## Alles was einmal rausgelassen wurde, darf auch zurück antworten
$FW -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
## Alles was falsch läuft loggen
$FW -A INPUT $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-INPUT-ACCESS "
## und verwerfen
$FW -A INPUT -j DROP
