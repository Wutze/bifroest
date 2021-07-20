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

$FW -A OUTPUT -o lo -j ACCEPT
$FW -A OUTPUT -p icmp -j ACCEPT

$FW -A OUTPUT -p tcp -o $DEV_EXTERN -m multiport --dport 53,80,443 -j ACCEPT            ## http, https -> Gitlab/Updates
$FW -A OUTPUT -p udp -o $DEV_EXTERN -m multiport --dport 53,123 -j ACCEPT

$FW -A OUTPUT -p udp -o $DEV_EXTERN -m multiport --dport 53,123 -j ACCEPT 
$FW -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$FW -A OUTPUT $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-OUTPUT-ACCESS "
$FW -A OUTPUT -j DROP
