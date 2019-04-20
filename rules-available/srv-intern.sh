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

rulename="SRV-INT"
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
## Container"$rulename" definieren
$FW -N $rulename
########################################################
current_object_s[$count]="192.168.104.0/26"
current_object_d[$count]="0.0.0.0/0"

# Dinge die innerhalb des Inranets umfassend erlaubt sind
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> DMZ1
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -p icmp -j ACCEPT		## icmp
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> LAN1
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p icmp -j ACCEPT		## icmp
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN2 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> LAN2
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN2 -p icmp -j ACCEPT		## icmp

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.15 -p udp -m multiport --dport 123 -j ACCEPT            ## NTP-Server

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.2 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## pc
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -s 192.168.104.2 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## pc



## für die Updates des Servers
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.14 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## forum.home
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.16 -p tcp -m multiport --dport 80,143,443,993 -j ACCEPT          ## pgp.home
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.17 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## terminalserver
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.21 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## cryptpad
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.23 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## cloud.home/update rss

## VPN
$FW -A $rulename -i $DEV_INTERN -d $NET_VPN0 -j ACCEPT		# VPN


########################################################
