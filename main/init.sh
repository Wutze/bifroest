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

## als erstes alle Regeln loeschen
$FW -F
$FW -X
$FW -t nat -F

# nun neu aufbauen
# Initialisierung der Firewall mit dem Standard-Satus der weiter oben definiert ist
$FW -P INPUT $DEFAULT_STATUS
$FW -P FORWARD $DEFAULT_STATUS
$FW -P OUTPUT $DEFAULT_STATUS

# Erweitertes Logging nach /var/log/syslog ein/ausschalten
# Die Variable wird per Default in der firewall.conf gesetzt,
# sie kann aber auch mit ./firewall logon|logoff ein oder ausgeschaltet werden
case $LOGFW in
        0) LOG_LIMITER="-m limit" ;;
        1) LOG_LIMITER="";;
esac
