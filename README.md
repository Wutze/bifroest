# Installation

Das Firewallscript am besten nach ``` /opt/firewall/ ``` kopieren

git clone
```
cd /opt/
mkdir firewall
cd firewall
git clone https://github.com/Wutze/firewall
```

Download zip Datei
```
wget https://github.com/Wutze/firewall/archive/master.zip
unzip master.zip
mkdir /opt/firewall
cp -a firewall-master/. /opt/firewall
```

# Konfiguration

* ``` firewall.conf ```
Nicht jeder wird so viele Schnittstellen auf dem Router haben. Deswegen kann man die entsprechenden und nicht benutzten Variablen auch löschen, sie sind nicht unabdingbar notwendig, wenn die Schnittstellen nicht vorhanden sind. Sie dienen hier lediglich als Beispiel.

```
## per Default alles offen oder alles zu?!
DEFAULT_STATUS="DROP" 
#DEFAULT_STATUS="ACCEPT" 

## Schnittstellen definieren 
DEV_INTERN="eth1" 
DEV_EXTERN="ppp0" 
DEV_DMZ1="eth3" 
DEV_LAN1="eth0" 
DEV_LAN2="eth2" 
DEV_VPN1="tun0"
```
Auch die im weiteren angegebenen Netzwerke, Ports usw. sind oft nur dann von Interesse, wenn man sehr viele Clients im eigenen Netzwerk betreibt. Ebenfalls können die Namen der Variablen so angepasst werden, so dass man sich selbst eigene Namenskonventionen entwickelt, die man sich auch merken kann.

## Benutzung der Firewall, Starten, Stoppen usw.

* Mit dem Aufruf ``` ./firewall help ``` wird Dir der Hilfetext angezeigt.
* Die Firewall selbst kann dann mit ``` ./firewall start ``` oder ``` ./firewall stop ``` gestartet oder gestoppt werden.
* ``` ./firewall backup ``` erstellt ein Backup der funktionierenden Firewall derzeit nach ``` /tmp/ ```
* ``` ./firewall restore ``` spielt das Backup zurück. Ist die Firewall vorher nicht aktiv gewesen, nach dem Restore wird sie es sein.
* ``` ./firewall debug 1 ``` schaltet das erweiterte Logging in die ``` /var/log/syslog ``` ein. Im Normalfall sind die Einträge, die die Firewall tätigt, auf 3 Meldungen begrenzt, da sonst das Logfile zu groß werden würde.
* ``` ./firewall debug 0 ``` schaltet das Logging wieder in den Normalszustand zurück.

## Hinweis:

Der Einfachheit halber wird das Firewallscript mit jedem Funktionsaufruf vollständig gelöscht und neu aufgebaut. Falls jemand die Zugriffe auf diverse Regeln, z.B. mit collectd, loggen möchte, das wird nicht ohne weiteres funktionieren.

Weitere Funktionen sind derzeit in Arbeit.

# Anlegen der Regeln
## Default Rulesets

Die Default Regelsets sind ``` 98-input.sh ``` und  ``` 99-output.sh ```. Die Ziffern vor den Dateinamen sind notwendig und werden in genau dieser Reihenfolge abgearbeitet. Es sollte keine Datei mit Nummern oberhalb 98 angelegt werden. Es sei den Du weißt genau was Du tust. Außerdem werden diese beiden Regelsets direkt in die Firewall eingetragen, da sie für nur für OUTPUT und INPUT auf dem Router stehen. Alle weiteren Regeln definieren die anderen Dateien, die den Zugriff der Netzwerk-Clients regeln.

Die hier mitgelieferte input.sh lässt jegliche Kommunikation aus den internen Netzwerken mit dem Router zu. Du musst sie also so anpassen, dass nur die Kommunikation erlaubt ist, die tatsächlich erlaubt sein soll. Denn denke daran, die meisten Hackerangriffe passieren meist aus dem internen Netzwerk!

Die output.sh ist hier schon etwas feiner justiert. Sie definiert, wohin der Router Antworten liefern bzw. welche Kommunikation er selbst aufbauen darf.

Damit sollten die Regeln für den Router klar sein.

## Network-Rulesets

Es sind einige Beispiel-Regelsets unter ``` rules-available/ ``` enthalten. Jedes zeigt verschiedene Variationen und sollte daher aus sich heraus selbsterklärend sein.

# Debugging

Es gibt zwei verschiedene Debugging Lösungen.

1. Debug der Regelsets
2. Debug des Firewall-Scripts

## Debug Rulesets

Steuern lässt sich das Debugging der Regelsets in der firewall.conf. Die Variable ``` DEBUG_FW=1 ``` schaltet das Debugging ein und zeigt jeden Regelfall an, der nicht den Bedingungen entspricht die Du gesetzt hast. Hast Du das Debugging Standardmaäßig ausgeschaltet, was sinnvoll ist da sonst das syslog-File sehr voll werden kann, kannst Du mit ``` /opt/firewall/firewall debug 1 ``` das Logging einschalten, mit "0" dann natürlich wieder ausschalten.

## Script-Debug

Mit ``` DEBUG=1 /opt/firewall/firewall [Options] ``` wird das Debugging des Scriptes eingeschaltet. Hier kannst Du mögliche (Schreib-) Fehler in Deinen Regelsets erkennen.

# Regeln einschalten

Die Links _müssen_ die Endung ``` sh ``` besitzen, da sie sonst nicht automatisch eingelesen und aktiviert werden!

``` ln -s /opt/firewall/rules-available/ [ Dateiname.sh ] /opt/firewall/rules-enable/ [dateiname.sh] ```

# Snippets

Im Ordner snippets:

1. Vorausgesetzt Du hast Multitail installiert, dann füge die Zeilen aus der multitail.conf in die Datei /etc/multitail.conf ein. Durch den Aufruf von: ``` multitail -s 2 -cS microwall /var/log/syslog ``` hast Du dann eine farblich abgestufte Ausgabe, die das auffinden von Fehlern vereinfacht.

2. Ein Start/Stop-Script für ``` /etc/init.d/ ```, einfach da hinein kopieren. Fertig



