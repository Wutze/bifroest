# Simple Firewall

## German

Das ist ein vollständiges und getestetes Beispiel, um einen Webserver per Firewall abzusichern.

Es werden nur Zugriffe auf SSH, HTTP und HTTPS zugelassen. Zusätzlich kann man den Server auch per "Ping" erreichen. Alle anderen Anfragen an den Server werden blockiert. Zusätzlich gibt es eine Sperre von 60 Sekunden, wenn mehr als 4 Anfragen pro Sekunde an den Server gerichtet werden. Der Wert ist mit Absicht sehr klein gehalten. Es kann deswegen durchaus passieren, dass ihr Euch für 60 Sekunden selbst aussperrt. Das passiert meist dann, wenn ihr auf die Webseite zugreift und wenig später per SSH auf die Shell zugreifen wollt.

Ihr könnt mit den Zahlen durchaus etwas spielen und an die eigenen Bedürfnisse anpassen.

## English

This is a complete and tested example of securing a web server via firewall.

Only accesses to SSH, HTTP and HTTPS are permitted. In addition, the server can also be reached via "ping". All other requests to the server are blocked. In addition, there is a block of 60 seconds if more than 4 requests per second are made to the server. The value is intentionally kept very small. It can therefore happen that you lock yourself out for 60 seconds. This usually happens when you access the website and a little later want to access the shell via SSH.

You can play around with the numbers and adapt them to your own needs.
