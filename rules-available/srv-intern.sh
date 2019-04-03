#!/usr/bin/env bash
#
# FIREWALL SCRIPT
# (c) M. Glotz 2006-17 Version 3.0
# Einfaches und übersichtliches Script welches direkt aus der /etc/rc.local
# aufgerufen werden kann
#
#
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

# der interne DNS Server darf natürlich auch nach draußen telefonieren
# als einziger!
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS

# Der NTP-Server muss auch erreichbar sein
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.15 -p udp -m multiport --dport 123 -j ACCEPT            ## NTP-Server

## Ein PC der Dinge darf, hier aber noch im flaschen Netzwerksegment steckt.
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.2 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## pc
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -s 192.168.104.2 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## pc



## für die Updates der Internen Server
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.14 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## forum
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.16 -p tcp -m multiport --dport 80,143,443,993 -j ACCEPT          ## terminalserver.pgp.home
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.17 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## terminalserver
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.21 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## cryptpad




########################################################
