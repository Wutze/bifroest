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

rulename="SAMSUNG1"

########################################################
##     Diese Werte ab hier nicht mehr verändern       ##
########################################################
## Der Zähler der das Arry "forwardrule[n]" hoch zählt
count=$(( $count + 1 ))
## Das zu definierdende Array
## Damit wird erreicht, dass jede eingelesene Datei
## in einem eigenen Container abgespeichert wird
## welches beim abarbeiten unter /main/ende.sh
## dann die Firewall zusammenfügt
forwardrule[$count]="$rulename"
## Container"$rulename" definieren
$FW -N $rulename

########################################################
# Samsung TV
########################################################
SAMSUNG1="192.168.104.248/29"
current_object_s[$count]=$SAMSUNG1
current_object_d[$count]="0.0.0.0/0"

## log-ingestion-eu.samsungacr.com
$FW -A $rulename -i $DEV_INTERN -s $SAMSUNG1 -o $DEV_EXTERN -d 52.210.168.19 -j DROP
$FW -A $rulename -i $DEV_INTERN -s $SAMSUNG1 -o $DEV_EXTERN -d 52.209.220.122 -j DROP


$FW -A $rulename -i $DEV_INTERN -s $SAMSUNG1 -o $DEV_EXTERN -j ACCEPT
$FW -A $rulename -i $DEV_INTERN -s $SAMSUNG1 -o $DEV_INTERN -j ACCEPT

$FW -A INPUT -s $SAMSUNG1 -j ACCEPT
$FW -A OUTPUT -d $SAMSUNG1 -j ACCEPT
