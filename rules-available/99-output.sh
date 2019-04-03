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

# Der Router soll eigentlich nur Pakete transportieren (FORWARD).
# Ausnahmen sind unter Umständen eingehende (Input) Anfragen
# nach Ping, die er auch beantworten darf (Output).
# Wichtig! Die Firewall blockiert auch die Kommunikation mich sich selbst,
# also localhost und muss demnach ebenfalls angegeben werden!

## Allen lokalen Diensten erlauben irgend wo hin zu gehen (Updates z.B.)
$FW -A OUTPUT -o lo -j ACCEPT
## Du darfst auch selbst rumpingen .... ;o)
$FW -A OUTPUT -p icmp -j ACCEPT                                         # ping

# Der Router muss auch selbst kommunizieren dürfen
$FW -A OUTPUT -p tcp -o $DEV_DMZ1 -m multiport --dport 80,443 -j ACCEPT		## http, https -> Gitlab/Updates
$FW -A OUTPUT -p tcp -o $DEV_EXTERN -m multiport --dport 80,443 -j ACCEPT		## http, https -> Internet/Updates

$FW -A OUTPUT -p udp --dport 53 -d $DNS_INTERN1 -j ACCEPT		## DNS Serverabfrage zulassen nur intern
$FW -A OUTPUT -o $DEV_INTERN -d $DNS_INTERN1 -p udp -m multiport --dport 67 -j ACCEPT	# DHCP
$FW -A OUTPUT -o $DEV_DMZ1 -p udp -m multiport --dport 67 -j ACCEPT		# DHCP
$FW -A OUTPUT -o $DEV_INTERN -p udp -m multiport --dport 123 -j ACCEPT	# NTP

# Spezialfall proxy_pass mit Nginx und Zugriff auf Webserver in der DMZ
$FW -A OUTPUT -p tcp -o $DEV_DMZ1 -m multiport --dport 80,81,443,3000 -j ACCEPT		## Proxy-Weiterleitungen
$FW -A OUTPUT -p tcp -o $DEV_INTERN -m multiport --dport 80,3000 -j ACCEPT		## Proxy-Weiterleitungen

## Tor Netzwerk
$FW -A OUTPUT -p tcp -o $DEV_EXTERN -m multiport --dport 9001 -j ACCEPT		## Tor
$FW -A OUTPUT -p tcp -o $DEV_INTERN -m multiport --dport 6100 -j ACCEPT		## Tor
#$FW -A OUTPUT -o $DEV_EXTERN -j ACCEPT		## Tor

#$FW -A OUTPUT -p tcp --dport 53 -d $DNS3 -j ACCEPT		## DNS Serverabfrage zulassen nur intern

#$FW -A OUTPUT -p tcp --dport 2003 -d 192.168.104.111 -j ACCEPT		## Collectd -> Ziel: db.home

#$FW -A OUTPUT -p udp -o $DEV_INTERN -m multiport --dport 67,68 -j ACCEPT
#$FW -A OUTPUT -p udp -o $DEV_DMZ1 -m multiport --dport 67,68 -j ACCEPT
#$FW -A OUTPUT -p udp -o $DEV_LAN1 -m multiport --dport 67,68 -j ACCEPT

## Alles was einmal rausgelassen wurde, darf auch zurück antworten
$FW -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
## Alles was falsch läuft loggen
$FW -A OUTPUT $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-OUTPUT-ACCESS "
## und verwerfen
$FW -A OUTPUT -j DROP
