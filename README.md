<p align="center">
<img src="https://xvpn.ddnss.org/giT/bifroest-logo_klein.png" width="314" height="61" alt="bifroest"></a>
</p>

# Bifroest - Firewallscript

Getestet unter Ubuntu, Debian 9

# Installation

Das Firewallscript am besten nach ``` /opt/bifroest/ ``` kopieren

git clone
```
cd /opt/
git clone https://github.com/Wutze/bifroest.git
```

Download zip Datei
```
wget https://github.com/Wutze/bifroest/archive/master.zip
unzip master.zip
mkdir /opt/bifroest
cp -a firewall-master/. /opt/bifroest
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

Steuern lässt sich das Debugging der Regelsets in der firewall.conf. Die Variable ``` DEBUG_FW=1 ``` schaltet das Debugging ein und zeigt jeden Regelfall an, der nicht den Bedingungen entspricht die Du gesetzt hast. Hast Du das Debugging Standardmaäßig ausgeschaltet, was sinnvoll ist da sonst das syslog-File sehr voll werden kann, kannst Du mit ``` /opt/bifroest/firewall debug 1 ``` das Logging einschalten, mit "0" dann natürlich wieder ausschalten.

## Script-Debug

Mit ``` DEBUG=1 /opt/bifroest/firewall [Options] ``` wird das Debugging des Scriptes eingeschaltet. Hier kannst Du mögliche (Schreib-) Fehler in Deinen Regelsets erkennen.

# Regeln einschalten

Die Links _müssen_ die Endung ``` sh ``` besitzen, da sie sonst nicht automatisch eingelesen und aktiviert werden!

``` ln -s /opt/bifroest/rules-available/ [ Dateiname.sh ] /opt/bifroest/rules-enable/ [dateiname.sh] ```

# Snippets

Im Ordner snippets:

1. Vorausgesetzt Du hast Multitail installiert, dann füge die Zeilen aus der multitail.conf in die Datei /etc/multitail.conf ein. Durch den Aufruf von: ``` multitail -s 2 -cS bifroest /var/log/syslog ``` hast Du dann eine farblich abgestufte Ausgabe, die das auffinden von Fehlern vereinfacht.

2. Ein Start/Stop-Script für ``` /etc/init.d/ ```, einfach da hinein kopieren. Fertig

## Donation

[![Donate PayPal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/huwutze)


# English Translation

Copy the firewallscript to ``` /opt/bifroest/ ``` best

git clone
```
cd /opt/
git clone https://github.com/Wutze/bifroest.git
```

Download zip Datei
```
wget https://github.com/Wutze/bifroest/archive/master.zip
unzip master.zip
mkdir /opt/bifroest
cp -a firewall-master/. /opt/bifroest
```

# Configuration

* ``` firewall.conf ```

Not everyone will have so many interfaces on the router. Therefore you can also delete the corresponding and unused variables, they are not indispensable if the interfaces are not available. They serve here only as an example.

```
## Default all open or all closed?!
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

The networks, ports, etc. listed below are also often only of interest if you have a large number of clients on your own network. The names of the variables can also be adapted so that you can develop your own naming conventions, which you can also remember.

## Benutzung der Firewall, Starten, Stoppen usw.

* ``` ./firewall help ``` view helptext
* ``` ./firewall start ``` or ``` ./firewall stop ``` start or stop firewall
* ``` ./firewall backup ``` backup firewall to ``` /tmp/ ```
* ``` ./firewall restore ``` restore firewall
* ``` ./firewall debug 1 ``` enable extended logging ``` /var/log/syslog ```
* ``` ./firewall debug 0 ``` disable extended logging

## Note:

For the sake of simplicity, the firewall script is completely deleted and rebuilt with each function call. If someone wants to log access to various rules, e.g. with collectd, this will not work without further ado.

Further functions are currently in the works.

# Create the rules
## Default Rulesets

The default rule sets are ```` 98-input.sh ``` and ``` 99-output.sh ```. The digits before the file names are necessary and are processed in exactly this order. No file with numbers above 98 should be created. It is that you know exactly what you are doing. In addition, these two rule sets are entered directly into the firewall, since they only stand for OUTPUT and INPUT on the router. All other rules define the other files that control the access of the network clients.

The input.sh provided here allows any communication from the internal networks with the router. So you have to adjust it so that only the communication that should actually be allowed is allowed. Remember, most hacker attacks happen mostly from the internal network!

The output.sh is a bit finer adjusted here. It defines where the router is allowed to send answers or which communication it is allowed to establish itself.

So the rules for the router should be clear.

## Network rulesets

There are some example rule sets under ``` rules-available/ ```. Each shows different variations and should therefore be self-explanatory in itself.

# Debugging

There are two different debugging solutions.

1. debug rule sets
2. debug the firewall script

## Debug Rulesets

You can control the debugging of rule sets in the firewall.conf. The ``` DEBUG_FW=1 ``` variable turns on debugging and displays any rule case that does not match the conditions you set. If you have disabled debugging by default, which makes sense otherwise the syslog file can get very full, you can enable logging with ``` /opt/bifroest/firewall debug 1 ``, then disable logging with "0".

## Script debug

With ``` DEBUG=1 /opt/bifroest/firewall [Options] ``` the debugging of the script is enabled. Here you can see possible (write) errors in your rule sets.

# Enable rules

The links _must_ have the extension ``` sh ````, otherwise they will not be read and activated automatically!

``` ln -s -s /opt/bifroest/rules-available/ [ filename.sh ] /opt/bifroest/rules-enable/ [filename.sh] ```

# Enable rules

The links _must_ have the extension ``` sh ````, otherwise they will not be read and activated automatically!

``` ln -s -s /opt/bifroest/rules-available/ [ filename.sh ] /opt/bifroest/rules-enable/ [filename.sh] ```

# Snippets

In the snippets folder:

1. assuming you have Multitail installed, add the lines from multitail.conf to /etc/multitail.conf. By calling: ``` multitail -s 2 -cS bifroest /var/log/syslog ``` you will have a colored output that makes it easier to find errors.

2. a start/stop script for ``` /etc/init.d/ ```, just copy it in. Done





