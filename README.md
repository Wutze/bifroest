# Intro

## Warum ein weiteres Firewall-Script?

2006 fing ich an verstehen zu wollen, was so eine Firewall alles tun kann. Alle Programme mit denen man Firewall-Regeln erstellen konnte funktionierten zwar hervorragend, aber wenn man sich mit ``` iptables -L ``` die Einträge ansehen wollte, ist es eher ein unstrukturiertes Durcheinander, welches man zu Gesicht bekommt. So entstand mit Version 1 die Idee ein eigenes Script zu schreiben, welches zuerst immer in der "/etc/rc.local" zu finden war.

Über die Jahre veränderte das Script immer mehr sein Gesicht. Viele Regeln kamen dazu, viele verschwanden. Denn jeder neue Host im Netzwerk benötigt einen eigenen und ganz auf ihn zugeschnittenen Eintrag. Mit Version 2 kam dann schon etwas mehr Übersicht in das Script. Es wurde das Logging mit eingebaut, so dass man auch Kommunikation erkennen konnte, welche diverse Clients aufbauen wollten. Insbesondere Spiele sind oft nicht gut dokumentiert und kommunizierten über Ports, die normalerweise nicht geöffnet sein sollten. Aber auch das genügte irgendwann nicht mehr. Inzwischen hat das Hauptscript weit über 500 Zeilen und wurde so unübersichtlich, so dass sich Fehler hätten einschleichen können. Zudem verwende ich das Firewall-Script inzwischen Standardmäßig auf allen von mir aufgebauten Routern, was Updates schwierig gestaltete.

Die jetzt veröffentlichte Version 3 kann man durchaus als die Summe meiner Erfahrungen bezeichnen. Insbesondere die "Backup-Funktion" ist aus der Vielzahl meiner fehlgeschlagenen Regeländerungen entstanden. Tippfehler in den einzelnen Regeln, zu viel gesetzte Zeichen usw., führen immer dazu, dass die Firewall alle Ports schießt und damit keinerlei Kommunikation, weder mit sich selbst noch nach außen zulässt. So man Zugriff auf den lokalen Computer hat, ist die vorhergehende Konfiguration recht schnell wieder einlesbar und die Firewall funktioniert. Dann kann man sich in aller Ruhe auf die Suche nach dem Fehler begeben und von vorn beginnen.

Zuguterletzt habe ich häufig das Problem mit Dokumentationen, dass diese zum einen nicht selten unvollständig sind, zum anderen oft nur Fragmente des Codes besitzen, der das gesamte Script ausführlich dokumentiert und auch auf Anhieb funktionieren lässt. Theorie ist schön, wenn etwas zum üben in der Praxis auch sofort funktioniert, ist es meiner Meinung nach besser.

## Ausblick

* Ich möchte die Backup-Funktion künftig etwas automatisieren. Das heißt, verfügbar machen für Computer, auf denen man keinen Remote-Zugriff zum X-Server bzw. physisch zur Konsole besitzt. Das ist häufiger der Fall als man denkt. Insbesondere zu Hause werden oft ausrangierte Computer als Firewall benutzt, die in irgend einer Ecke stehen, ohne Monitor und Tastatur. Besteht ein Backup und die Firewall wurde mit einem Fehler neu gestartet, hat der Router keinen Zugang mehr zum Internet, auch die lokalen Ports per SSH wären dann blockiert. Nach einem Zeitraum X würde die Firewall dann automatisch den Urzustand wiederherstellen, der Zugriff auf den Router wäre damit gewährleistet.
* Weiterhin soll das Script irgendwann eine Setup-Routine bekommen, die zumindest den Einstieg und die Erstkonfiguration der Firewall automatisch übernimmt.
* Mehrsprachig wäre auch keine üble Idee ;o)

## Installation

Sobald Du diese Scriptsammlung herunter geladen hast, entpacke sie am besten nach ``` /opt/firewall ```. Dort kannst Du dann nach belieben die Anpassungen tätigen, die Du haben willst. Bitte sei Dir im klaren darüber, Updates die aus diesem Repository kommen betreffen nicht nur das Firewall Script selbst, sie können auch die Scripte im Ordner ``` /main/ ``` betreffen. Deswegen sei vorsichtig mit Änderungen in diesen Scripten. Lege lieber eigene und neue Regeln an, die Du dann jederzeit in den Ordner ``` /rules-available ``` kopierst. Mit einem Symlink auf die jeweilige Datei in den Ordner ``` /rules-enabled ``` und einem entsprechenden reload der Firewall, werden Deine neuen Scripte automatisch mit in Deine Firewall eingefügt.

## Beachte:
* Jede Datei im Ordner ``` /rules-available ``` sollte einen eigenen spezifischen Containernamen besitzen. Doppelte Namen werden das gesamte Script nicht korrekt funktionieren lassen und die Firewall wird nicht funktionieren, im schlimmsten Fall wird der Computer nicht mehr erreichbar sein.
* Solltest Du das Script automatisch mit jedem Start des Computers ausführen, dann wird auch ein Neustart des Computers keine Lösung sein. Du musst in dem Fall Zugriff auf die Konsole auf dem lokalen Rechner besitzen, um den Fehler beheben zu können!

### Konfiguration

* ``` firewall.conf ```
Nicht jeder wird so viele Schnittstellen auf dem Router haben. Deswegen kann man die entsprechenden und nicht benutzten Variablen auch löschen, sie sind nicht unabdingbar notwendig, wenn die Schnittstellen nicht vorhanden sind. Sie dienen hier lediglich als Beispiel.

```
## per Default alles offen oder alles zu?!
#DEFAULT_STATUS="DROP" 
DEFAULT_STATUS="ACCEPT" 

## Schnittstellen definieren 
DEV_INTERN="eth1" 
DEV_EXTERN="eth0" 
DEV_DMZ1="eth3" 
DEV_LAN1="eth0" 
DEV_LAN2="eth2" 
DEV_VPN1="tun0"
```
Auch die im weiteren angegebenen Netzwerke, Ports usw. sind oft nur dann von Interesse, wenn man sehr viele Clients im eigenen Netzwerk betreibt. Ebenfalls können die Namen der Variablen so angepasst werden, so dass man sich selbst eigene Namenskonventionen entwickelt, die man sich auch merken kann.

### Benutzung der Firewall, Starten, Stoppen usw.

* Mit dem Aufruf ``` ./firewall help ``` wird Dir der Hilfetext angezeigt.
* Die Firewall selbst kann dann mit ``` ./firewall start ``` oder ``` ./firewall stop ``` gestartet oder gestoppt werden.
* ``` ./firewall backup ``` erstellt ein Backup der funktionierenden Firewall derzeit nach ``` /tmp/ ```
* ``` ./firewall restore ``` spielt das Backup zurück. Ist die Firewall vorher nicht aktiv gewesen, nach dem Restore wird sie es sein.
* ``` ./firewall debug 1 ``` schaltet das erweiterte Logging in die ``` /var/log/syslog ``` ein. Im Normalfall sind die Einträge, die die Firewall tätigt, auf 3 Meldungen begrenzt, da sonst das Logfile zu groß werden würde.
* ``` ./firewall debug 0 ``` schaltet das Logging wieder in den Normalszustand zurück.

### Hinweis:

Der Einfachheit halber wird das Firewallscript mit jedem Funktionsaufruf vollständig gelöscht und neu aufgebaut. Falls jemand die Zugriffe auf diverse Regeln, z.B. mit collectd, loggen möchte, das wird nicht ohne weiteres funktionieren.

Weitere Funktionen sind derzeit in Arbeit.

## Fehlersuche/Neue Clients identifizieren und Regeln erarbeiten

Ist das Logging mit ``` ./firewall debug 1 ``` eingeschaltet, wird jeder einzelne Zugriff, den die Firewall blockiert, auf diese Weise ins Syslog geschrieben. Die Angaben sind im Klartext enthalten. Du musst also den Bezug zwischen der aufgelisteteten Schnittstelle, hier z.B. ``` ens18 ```, mit der Variablen aus Deiner Konfiguration gleichsetzen.

``` Oct  1 11:07:33 bifroest kernel: [939983.373924] [FW] DENY-TRANSPORT-ACCESS IN=ens20 OUT=ens18 MAC=d2:80:bc:af:e7:a3:d6:d2:ba:45:19:8b:08:00 SRC=172.16.16.57 DST=192.168.104.15 LEN=76 TOS=0x00 PREC=0x00 TTL=63 ID=26125 DF PROTO=UDP SPT=54974 DPT=123 LEN=56 ```

Für Dich von Interesse ist alles jenseits der Angaben zum Router.

``` Oct  1 11:07:33 bifroest kernel: [939983.373924] ``` sind lediglich Informationen zum Router und der Uhrzeit.

* ``` [FW] DENY-TRANSPORT-ACCESS ``` verrät jetzt welche Regel betroffen ist.
* ``` IN=ens20 OUT=ens18 ``` Über welche Schnittstellen sollte kommuniziert werden und von wo nach wo sollte diese Kommunikation stattfinden
* ``` MAC=d2:80:bc:af:e7:a3:d6:d2:ba:45:19:8b:08:00 ``` Die MAC-Adressen wirst Du nicht benötigen.
* ``` SRC=172.16.16.57 DST=192.168.104.15 ``` Zeigt an welcher Computer den Verstoss verursacht hat und wohin er telefonieren wollte.
* ``` LEN=76 TOS=0x00 PREC=0x00 TTL=63 ID=26125 DF ``` sind wieder Einträge, die Du zumeist nicht benötigen wirst.
* ``` PROTO=UDP SPT=54974 DPT=123 ``` Wichtig wird sein welches Protokoll, hier UDP benutzt wird und welcher Ziel-Port angesprochen werden soll. Port 123 verrät uns das wahre Ziel, hier NTP, also ein Zeitserver sollte angefragt werden.
* ``` LEN=56 ``` ist erst mal auch nicht von Interesse

## Neue Regel erstellen

Möchtest Du nun eine neue Regel erstellen, kannst Du mit den hier gewonnenen Informationen die richtigen Einträge erhalten.

Angenommen Du hast eine Datei mit dem Namen timeserver.sh im Ordner ``` /rules-available ``` liegen, in dem alle Computer aufgelistet sind die einen Timeserver benutzen dürfen, sähe der Eintrag für die neu Regel nun so aus:

``` $FW -A $rulename -p udp -i $DEV_INTERN -o $DEV_EXTERN -s 172.16.16.57 -m multiport --dport 123 -j ACCEPT ```

**Ausführlich erklärt:**

* ``` $FW ``` ist die Variable die den Programmnamen "iptables" enthält
* ``` -A $rulename ``` ist der Container, in der die neue Regel erstellt werden soll **[*1]**
* ``` -p udp ``` spezifiziert den Protokolltyp
* ``` -i $DEV_INTERN ``` spezifiziert die Netzwerkkarte von der aus die eingehende Verbindung kontrolliert werden soll
* ``` -o $DEV_EXTERN ``` setzt die Netzwerkkarte über die die Kommunikation weitergeleitet werden darf
* ``` -s 172.16.16.57 ``` sagt, welcher Computer mit welcher IP-Adresse diese Kommunikation erlaubt wurde. Ohne diesen Eintrag würden sonst alle Clients die über diesen Weg mit NTP kommunizieren wollen der Zugang gewährt.
* ``` -m multiport --dport 123 ``` definiert den entsprechenden Port. hier NTP
* ``` -j ACCEPT ``` erlaubt dann diese Kommunikation.

**[*1]** $rulename ist die im Script vorhandene Variable, die den Container definiert. Wenn Du eine eigene Datei nur die die Kommunikation mit NTP-Server anlegst, könnte diese den Namen "ACCESS-NTP" tragen. Im Logfile ``` /var/log/syslog ``` würden dann Fehler mit diesem Namen auftauchen und leichter erkennbar.

Jede neue Regel muss eine Erlaubnis (ACCEPT) sein, da ja jede andere Kommunikation von vornherein nicht erlaubt wurde (DROP). Regeln mit "DROP" machen daher in den meisten Fällen keinerlei Sinn und würden die Scripte nur unnötig aufblähen und damit unübersichtlich werden lassen. Willst Du jedoch erreichen dass Anfragen per NTP alle auch explizit im Log erscheinen, so ist zuerst diese Regel, nach dem anlegen des Conainers, eine wertvolle Hilfe:

``` $FW -A $rulename -p udp -m multiport --dport 123 -j DROP ```

Damit sperrt man explizit nochmals jede Kommunikation, erreicht damit aber ein Logging welches auch anzeigt, dass es sich um einen NTP-Block handelt. Das erleichtert die Suche nach Fehlern, da üblicherweise sonst nur "DENY-TRANSPORT" angezeigt würde.

## Der Überwachung ein Schnippchen schlagen

Ich blocke konsequent z.B. alle Anfragen an die Zeitserver. Denn mit Hilfe dieser Abfragen können durchaus auch Rückschlüsse auf die Anzahl der Geräte im privaten Netzwerk gezogen werden. Daher macht sich ein eigener Zeitserver innerhalb des privaten Netzwerkes immer bezahlt. Zudem behält man stets die Kontrolle über die eigenen Geräte. Das ist insbesondere dann wichtig, weil es oftmals Geräte gibt, denen die Zeitserver fest einprogrammiert worden sind. Diese ignorieren häufig die vom DHCP übergebenen Parameter. Selbigs gilt im übrigen auch für die DNS-Server. Sehr oft werden zuerst alle Google-Server (oder sogar eigene) abgefragt, ehe der Server zum Zuge kommt, der per DHCP vorgegeben worden ist.
