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

## funktionstüchtiges Beispiel-Script
## Du kannst es einschalten mit:
## "firewall enable example"
## Dadurch wird ein Sym-Link in den Ordner rules-enable erstellt,
## der durch das Firewall-Script während des Starts eingelesen wird

## Der Regel-Name
## der Übersicht halber am besten komplett in Großschreibung
## da der Text auch im /var/log/syslog dann auftaucht
rulename="TRANSPORT_SPEZIAL"

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
# Diese Angaben erfordern etwas mehr Wissen mit dem Thema Subnetting
# 
# Wer viele Dateien in rules-enabled liegen hat, wird irgendwann
# den Wald vor lauter Bäumen nicht mehr sehen. Das Logging wird so
# unübersichtlich, so dass die einzelnen Regelsets besser unterscheidbar
# sein sollten. Also welche Regel blockt denn nun mein Device X?
# Zudem können Fehler in den anderen Regeln dazu führen, dass plötzlich
# Geräte auf Wegen kommunizieren, auf denen sie das nicht sollten.
#
# Um bei der Verwendung vieler einzelner Regelsets die Übersicht zu behalten,
# sollte man die Globalen Angaben in den FORWARD-Regeln etwas beeinflussen.
# Subnets berechnen kann man hier:
# https://www.heise.de/netze/tools/netzwerkrechner/

# Diese Angabe bezieht das Netzwerk aus der firewall.conf
# NET_INTERN="192.168.104.0/24"
# Damit eine Zuordnung zum Script besteht, wird auch dieser Wert in
# einem Array gespeichert.
# Das erste Array ist die Herkunft (Source)
# Das zweite Array definiert das Netzwerk mit wohin (Destination)
# 0.0.0.0/0 bedeutet nach überall hin.
# Wer das nun eingrenzen möchte auf seine Internen Netzwerke, kann hier auch
# NET_LAN1="10.10.10.0/24" benutzen, was dann nur Kommunikation
# in dieses angegebene Netzwerk zulassen wird. Damit könnte man sich
# in den nachfolgenden Regeln die Einträge -o $DEV_EXTERN z.B. sparen
# da hier das zu erreichende Netzwerk selbst schon angegeben worden ist.
# Aber Vorsicht! In zwei Dateien das selbe Subnetz oder gar Überschneidungen
# der Subnetze, wird immer zu Fehlern führen! Eine saubere Dokumentation
# ist hier unbedingte Voraussetzung!

#current_object_s[$count]=$NET_INTERN
#current_object_d[$count]="0.0.0.0/0"

# Sind beide Zeilen auskommentiert, werden die entsprechenden Einträge
# in der Firewall nichtgesetzt. Auch hier Vorsicht!



## Kurz zur Erklärung:
## Das Gerät mit der IP-Adresse darf aus dem internen Netzwerk nach draußen telefonieren
## jedoch darf diese Kommunikation nur über den Port 57500 geschehen, tcp
$FW -A $rulename -p tcp -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.110.30 -m multiport --dport 57500 -j ACCEPT

## In dieser Datei kann man auch weitere Regeln im Regelset "INPUT" hinzufügen,
## ohne die Datei "input.sh" selbst entsprechend verändern zu müssen,
## wenn der Router selbst auf Aktionen dieses Gerätes reagieren soll. Damit kann
## es etwas übersichtlicher werden, wenn man alte Regeln löschen möchte, damit diese
## nicht übersehen werden und als offenes Loch im System verbleiben.
## Ein zusätzlicher Eintrag in der Datei INput wäre jedoch sinnvoll, der auf diese
## Regel in dieser Datei hinweist.
$FW -A INPUT -p tcp -i $DEV_INTERN -s 192.168.110.30 -m multiport --dport 57500 -j ACCEPT


