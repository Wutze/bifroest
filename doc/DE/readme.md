# Dokumentation zum Firewallscript

**Diese Firewall und Dokumentation, aufbauend auf iptables, sollte auch für blutige Anfänger geeignet sein. Die Dokumentation habe ich nach besten Wissen geschrieben und so ausführlich wie möglich. Diese Schritt für Schritt Anleitung wurde genau so von mir getestet.**

Viel Spaß

**Du hast zwei verschiedene Möglichkeiten Deine Firewall aufzubauen.**

1. Netzwerk bezogene Konfiguration<br  />
Vorteil: Wenige Dateien<br  />
Nachteil: Viele Regelsets (Unübersichtlich)

2. Host bezogene Konfiguration<br />
Vorteil: Wenige Regelsets<br />
Nachteil: Viele Dateien

Du kannst unter bestimmten Voraussetzungen beide Varianten miteinander kombinieren, das braucht aber eine umfassende Planung und etwas Kenntnisse zur Verwendung von Subnets.

# Ein neues Regelset erstellen

Wenn Du das erste Mal mit Firewallregeln experimentierst, dann gehe Schritt für Schritt, wie in dieser Dokumentation beschrieben, vor. Das bewahrt Dich vor Fehlern, welche durch falsche Daten in den Scripten zu fatalen Folgen führen können.

Eine neue Datei beliebigen Namens mit folgendem Inhalt (ohne eigene Ergänzungen) im Verzeichnis ``` rules-available ``` anlegen:

```
#!/usr/bin/env bash
#
# Simple Firewall-Script with iptables
# only IPv4
# Your private Description

rulename="TEST"
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
$FW -N $rulename
current_object_s[$count]=""
current_object_d[$count]=""
```

Bitte dabei beachten, dass der Wert ``` rulename ``` eindeutig ist und nicht doppelt in Deiner Firewallkonfiguration vorkommt. Sonst wird die Firewall nicht so funktionieren wie Du das möchtest.

Ist die Datei gespeichert wechselst Du in das Verzeichnis ``` rules-enabled ```. Dort legst Du dann einen symbolischen Link mit ``` ln -s ../rules-available/ [dateiname.sh] [20-dateiname.sh] ``` an.

**Wichtig!**: Der Link benötigt die Endung *.sh, da die Datei sonst nicht eingelesen/aktiviert wird! Die Ziffer im Link liest die Datei in aufsteigender Reihenfolge ein. 

Nach dem Neustart der Firewall ist das Regelset, welches hier mit dem Namen TEST angegeben ist, aktiviert, hat jedoch keinerlei Funktionen.
Mit ``` iptables -nvL -t filter ``` kannst Du nun überprüfen, welche Einträge in der Firewall gemacht worden sind. Das Regelset "Test" sollte wie folgt aussehen:

```
Chain TEST (2 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    0     0 LOG        all  --  *      *       0.0.0.0/0            0.0.0.0/0            LOG flags 0 level 4 prefix "[FW] DENY-TEST "
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0        
```
In der FORWARD Policy sollte der Eintrag in dieser Form stehen.
```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 TEST       all  --  *      *       0.0.0.0/0            0.0.0.0/0           
    0     0 TEST       all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
```

Du siehst nun zwei Angaben **source** und **destination**, die jeweils mit 0.0.0.0/0 angegeben sind. Alle Einträge die zu dieser Regel gesetzt würden, erlauben damit den Zugriff nach überall hin. Eingehend wie Ausgehend. Das ist nun genau das was Du ganz sicher nicht möchtest. Das gleiche gilt für die beiden Einträge unter **in** und **out**, welches die betreffenden Schnittstellen definieren würde.

An dieser Stelle musst Du Dich endgültig entscheiden, ob Du eine Netzwerkkonfiguration oder Hostkonfiguration einrichten möchtest.

## Netzwerkweite Konfiguration

Unterscheiden musst Du nun, ob Du mehrere interne IP-Netzwerke benutzt oder ob es nur ein IP-Netzwerk ist. Das Beispiel geht an der Stelle auf nur ein verwendetes Netzwerk ein.

Um eine Netzwerkweite Konfiguration zu  erhalten, in der dann alle weiteren Einträge zu jedem einzelnen Gerät innerhalb des eigenen Netzwerkes gemacht werden müssen, bedarf eines Eintrages in der ``` current_object_s[$count]="" ```. Diese Variable definiert die Herkunft (Source) des IP-Netzes, welches Du benutzt. Der Eintrag würde dann 254 benutzbare IP-Adressen umfassen, was einer Standard-Konfiguration der üblicherweise aufzufindenen Netzwerke entspräche.

``` current_object_s[$count]="192.168.100.0/24" ```

Du kannst allerdings auch diesen Wert frei lassen, so dass die Firewall dann automatisch 0.0.0.0/0 eintragen würde. Nur so überlässt Du die Konfiguration in gewisser Weise dem Zufall. Es ist Deine Entscheidung, wie genau Du Deine Firewall einstellen und unter Kontrolle haben möchtest.

Die Variable ``` current_object_d[$count]="" ``` (Destination/Ziel) kann meist leer bleiben, sie wird immer mit 0.0.0.0/0, so man das Netzwerk (Source) in jede erlaubte und selbst definierte Richtung kommunizieren lassen möchte. Das wäre die Grundeinstellung, da die meisten eher selten, mehrere verschiedene interne IP-Netze in Benutzung haben werden. Zudem würden viele IP-Adressen im Internet nicht erreichbar gemacht. Hier solltest Du schon genau wissen was Du tust, da sonst Verbindungen ins Internet abgelehnt werden.

Mit ``` iptables -nvL -t filter ``` würde der Eintrag in der FORWARD-Policy nun diese Form besitzen.

```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 TEST       all  --  *      *       192.168.100.0/24     0.0.0.0/0           
    0     0 TEST       all  --  *      *       0.0.0.0/0            192.168.100.0/24     state RELATED,ESTABLISHED
```

Das Ruleset "TEST" besitzt noch keine weiteren Einträge, es sollte sich nicht verändert haben.

## Host bezogene Konfiguration

Hostbezogene Konfigurationen haben den Nachteil mehr Dateien in Anspruch zu nehmen. Gleichzeitig aber ist die Fehleranfälligkeit durch falsche Einträge im Firewallscript wesentlich geringer. Man verliert nicht die Übersicht, wenn man nur einem Teil der verwendeten Netzwerkgeräte Zugriff ins Internet gewähren will. Jetzt wird die IP des zu konfigurierenden Hosts benötigt, wonach der Eintrag dann so aussieht:

``` current_object_s[$count]="192.168.100.10/32" ```

Die FORWARD-Policy hat sich folgendermaßen verändert. Nur noch der Client mit der Source (IP) 192.168.100.10 darf überall hin kommunizieren, auch von überall her, darf nur mit dem Client interagiert werden. Eindeutig zu erkennen am fehlenden CIDR-Suffix "xxx.xxx.xxx.xxx/nn".

```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination    
    0     0 TEST       all  --  *      *       192.168.100.10       0.0.0.0/0           
    0     0 TEST       all  --  *      *       0.0.0.0/0            192.168.100.10       state RELATED,ESTABLISHED
```

### Beispiel
Der zu erstellende Inhalt der Datei würde zur Netzwerkweiten Konfiguration so aussehen:

```
#!/usr/bin/env bash
#
# Simple Firewall-Script with iptables
# only IPv4
# Your private Description

rulename="TEST"
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
$FW -N $rulename
current_object_s[$count]="192.168.100.0/24"
current_object_d[$count]=""
```

Wer noch etwas genauer sein möchte und spezielle Bereiche im Netzwerk definieren will, der kann das mit dem Netzwerkrechner von Heise.de erledigen. https://www.heise.de/netze/tools/netzwerkrechner/

## Die Regeln erstellen

Jede Firewall sollte standadrdmäßig so eingestellt sein, dass sie jede nicht explizit erlaubte Kommunikation blockiert. Diese Einstellung kannst Du kontrollieren in der firewall.conf. Diese Variable definiert den Default-Status Deiner Firewall: ``` DEFAULT_STATUS="DROP" ```

Gehen wir davon aus, Deine Firewall soll auf dem Internetrouter installiert werden und die Kommunikation Deiner Netzwerkgeräte zu Hause mit dem Internet regeln. Die IP-Adressen beziehen die Geräte von einem DHCP-Server innerhalb Deines Netzwerkes, der IP-Adressbereich ist 192.168.104.0/24, was 253 (*1) zur Verfügung stehenden IP-Adressen entspricht mit der Subnetmask 255.255.255.0.

(*1) Eine IP-Adresse wurde schon abgezogen, da diese der Router besitzt als feste IP)

### Vorübrlegungen

Du hast *n* verschiedene Clients mit den folgenden IP-Adressen:

* 192.168.100.1 (Router)
* 192.168.100.5 (Mobiltelefon A)
* 192.168.100.7 (Fernseher)
* 192.168.100.8 (Notebook)
* 192.168.100.9 (Tablet)
* 192.168.100.10 (Mobiltelefon B)
* 192.168.100.12 (Computer)
* 192.168.100.14 (Smart-Home)

Zuerst muss Du in Erfahrung bringen, welche Kommunikation welches Gerät wirklich dringend benötigt. Denn nicht jede Kommunikation ist erwünscht. Nicht zuletzt kannst Du damit die Geräte innerhalb Deines Netzwerkes so auch zum nutzen Deiner eigenen Dienste zwingen.

#### Immer benötigte Ports/TCP:

* 80 HTTP
* 443 HTTPS

Diese Ports sollten eigentlich für jedes Gerät, welches immer einen Internetzugriff benötigt, freigeschaltet werden. Nur die Smart-Home Anlage und das Tablet, mit wlechem Smart-Home gesteuert wird, sollen nicht ins Internet zugreifen dürfen dürfen. Du willst ja zum einen weder überwacht werden noch sollen die Geräte unerlaubt nach Hause telefonieren.

#### Zusätzlich benötigte Ports/TCP
Eine Liste der standardisierten Ports findest Du hier: https://de.wikipedia.org/wiki/Liste_der_standardisierten_Ports

Mailserverzugriffe: (Bitte informiere Dich dazu bei deinem Mailserver-Provider, welche Ports tatsächlich benötigt werden)

* 25 (SMTP)
* 110 (POP3)
* 143 (IMAP)
* 465 (SSL SMTP)
* 587 (TLS SMTP)
* 993 (SSL IMAP)
* 995 (SSL POP3)

Zusätzliche Ports/TCP

* 53 (DNS)*
* 5060 (VoIP)

Zusätzliche Ports/UDP

* 53 (DNS)*
* 123 (NTP)*
* 5060 (VoIP)

Eigentlich ist es nicht notwendig weitere Ports in seinen Freigeben zu berücksichtigen. Berücksichtigen solltest Du in jedem Fall die mit * gekennzeichneten Ports. Provider nutzen gern die anfallenden Logfiles der Server, um Rückschlüsse auf die Internetnutzung und die Anzahl der Geräte im Netzwerk zu erhalten. Du solltest Dir hier Gedanken machen, ob nicht zumindest DNS-Abfragen nur an den internen Router erlaubt sein sollten. Leider haben die wenigsten Router einen NTP-Server, so dass man die Zeitsynchronisation darüber nutzen kann.

### Geräte die nur im internen Netzwerk bleiben sollen

Der Aufbau einer neuen Firewallregel ist denkbar einfach. Es gibt zwei verschiedene Netzwerkschnittstellen

1. ppp0 -> die Internetverbindung mit der öffentlichen IP-Adresse
2. eth0 -> die interne Schnittstelle

Beide Schnittstellen sollten in der firewall.conf auf DEV_EXTERN (ppp0) und DEV_INTERN (eth0) definiert sein.

* ``` $FW ``` -> Variable mit dem Programmnamen ``` iptables ```
* ``` -A ```
* ``` $rulename ``` -> Variable mit dem im Script vergebenen Namen der Firewall-Regel, damit die Regel auch dahin gesetzt wird, wo sie sein soll
* ``` -i ``` -> Input-Device (Netzwerkschnittstelle
* ``` $DEV_INTERN ``` -> die aus der firewall.conf bezogene Eintrag zur internen Netzwerkschnittstelle
* ``` -o ``` -> Output-Device (Netzwerkschnittstelle)
* ``` $DEV_INTERN ``` -> die aus der firewall.conf bezogene Eintrag zur internen Netzwerkschnittstelle
* ``` -j ```
* ``` ACCEPT ``` -> Diese Regel darf

Zusammengesetzt sieht die Regel dann so aus:

``` $FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -j ACCEPT  ## nach Intern darf kommuniziert werden ```

## HTTP und HTTPS erlauben

* ``` $FW ``` -> Variable mit dem Programmnamen ``` iptables ```
* ``` -A ```
* ``` $rulename ``` -> Variable mit dem im Script vergebenen Namen der Firewall-Regel, damit die Regel auch dahin gesetzt wird, wo sie sein soll
* ``` -i ``` -> Input-Device (Netzwerkschnittstelle
* ``` $DEV_INTERN ``` -> die aus der firewall.conf bezogene Eintrag zur internen Netzwerkschnittstelle
* ``` -o ``` -> Output-Device (Netzwerkschnittstelle)
* ``` $DEV_EXTERN ``` -> die aus der firewall.conf bezogene Eintrag zur externen Netzwerkschnittstelle

Bis hier hin dürfte jetzt jedes einzelne Netzwerkgerät in das Internet. Genau das wollen wir unterbinden und steuern, weswegen es weitere EInträge benötigt:

* ``` -s ``` -> Netzwerksource als IP-Adresse des Clients
* ``` 192.168.100.8 ``` -> die IP-Adresse des Clients, dem diese Regel explizit zugeordnet wird

Mit diesem Eintrag dürfte nun das Notebook uneingeschränkt mit dem Internet kommunizieren, alle anderen Geräte nicht. Jedoch wollen wir nicht jede Kommunikation zulassen, weswegen noch folgende Einträge wichtig sind.

* ``` -p tcp ``` -> Protokoll TCP

Ab hier wären jetzt alle Pakete außer TCP gesperrt. Das genügt aber noch nicht.

* ``` -m multiport ``` -> wir möchten mehrere TCP-Ports angeben
* ``` --dport ``` -> Destination-Port, also das Ziel, welches erreicht werden soll
* ``` 80,443 ``` -> die Ports für HTTP und HTTPS

Abschließen der Regel

* ``` -j ```
* ``` ACCEPT ``` -> Diese Regel darf

Zusamengesetzt sieht die Regel nun so aus:

``` $FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.100.8 -p tcp -m multiport --dport 80,443 -j ACCEPT  ## Das Notebook darf ins Internet ```
















