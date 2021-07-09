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

# simple script for host with one ip-card/address
# webserver

$FW -A INPUT -i lo -j ACCEPT

$FW -A INPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$FW -A INPUT -s $NET_INTERN -j ACCEPT# Webserver erlauben
$FW -A INPUT -p tcp -i $DEV_EXTERN -m multiport --dport 22,80,443 -j ACCEPT     # Auf dem Router läuft ein Webserver, der darf Anfragen annehmen

$FW -I INPUT -p tcp --dport 22 -i $DEV_EXTERN -m state --state NEW -m recent --set
$FW -I INPUT -p tcp --dport 22 -i $DEV_EXTERN -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
$FW -I INPUT -p tcp --dport 80 -i $DEV_EXTERN -m state --state NEW -m recent --set
$FW -I INPUT -p tcp --dport 80 -i $DEV_EXTERN -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
$FW -I INPUT -p tcp --dport 443 -i $DEV_EXTERN -m state --state NEW -m recent --set
$FW -I INPUT -p tcp --dport 443 -i $DEV_EXTERN -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

$FW -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$FW -A INPUT $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-INPUT-ACCESS "
$FW -A INPUT -j DROP
