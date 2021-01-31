# Documentation for the firewall script

**This firewall and documentation, based on iptables, should also be suitable for complete beginners. I have written the documentation to the best of my knowledge and as detailed as possible. This step by step guide has been tested by me exactly like this.**

Have fun

**You have two different ways to set up your firewall.**

1. network related configuration<br />
Advantage: Few files<br />
Disadvantage: Many rule sets (confusing)

2. host related configuration<br />
Advantage: Few rule sets<br />
Disadvantage: Many files

You can combine both variants under certain conditions, but this requires extensive planning and some knowledge of the use of subnets.

## Create a new rule set

If you are experimenting with firewall rules for the first time, proceed step by step as described in this documentation. This will prevent you from making mistakes that can lead to fatal consequences due to incorrect data in the scripts.

Create a new file of any name with the following content (without your own additions) in the directory ``` rules-available ```:

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

Please make sure that the value ``` rulename ``` is unique and does not appear twice in your firewall configuration. Otherwise the firewall will not work as you want it to.

Once the file is saved, change to the directory ```` rules-enabled ```. There you create a symbolic link with ``` ln -s ../rules-available/ [filename.sh] [20-filename.sh] ```.

**Important!**: The link needs the extension *.sh, otherwise the file will not be read/activated! The number in the link reads the file in ascending order. 

After restarting the firewall, the rule set, which is specified here with the name TEST, is activated but has no functions.
With ```` iptables -nvL -t filter ```` you can now check which entries have been made in the firewall. The rule set "Test" should look like this:


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

You now see two specifications **source** and **destination**, each of which is specified as 0.0.0.0/0. All entries that would be set to this rule allow access to anywhere. Inbound as well as outbound. This is exactly what you do not want. The same applies to the two entries under **in** and **out**, which would define the relevant interfaces.

At this point you must finally decide whether you want to set up a network configuration or a host configuration.

## Network-wide configuration

You must now distinguish whether you are using several internal IP networks or whether it is only one IP network. At this point, the example deals with only one network in use.

In order to obtain a network-wide configuration, in which all further entries must be made for each individual device within the own network, an entry is required in the ``` current_object_s[$count]="" ``. This variable defines the source of the IP network you are using. The entry would then contain 254 usable IP addresses, which would correspond to a standard configuration of the networks usually found.

``` current_object_s[$count]="192.168.100.0/24" ```

However, you can also leave this value blank, so that the firewall would automatically enter 0.0.0.0/0. This is the only way to leave the configuration to a certain extent to chance. It is your decision how exactly you want to set your firewall and have it under control.

The variable ``` current_object_d[$count]="" ``` (destination/destination) can usually be left empty, it will always be set to 0.0.0.0/0 if you want the network (source) to communicate in any allowed and self-defined direction. This would be the default setting, as most people will rarely have several different internal IP networks in use. In addition, many IP addresses on the Internet would be made unreachable. You should know exactly what you are doing, otherwise connections to the internet will be rejected.

With ```` iptables -nvL -t filter ```` the entry in the FORWARD policy would now have this form.

```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 TEST       all  --  *      *       192.168.100.0/24     0.0.0.0/0           
    0     0 TEST       all  --  *      *       0.0.0.0/0            192.168.100.0/24     state RELATED,ESTABLISHED
```

The ruleset "TEST" does not yet have any further entries, it should not have changed.

## Host-related configuration

Host-related configurations have the disadvantage of taking up more files. At the same time, however, the susceptibility to errors due to incorrect entries in the firewall script is considerably lower. One does not lose the overview if one only wants to grant access to the Internet to some of the network devices used. Now the IP of the host to be configured is needed, after which the entry then looks like this:

``` current_object_s[$count]="192.168.100.10/32" ```

The FORWARD policy has changed as follows. Only the client with the source (IP) 192.168.100.10 is allowed to communicate everywhere, even from everywhere, only the client may be interacted with. Clearly recognisable by the missing CIDR suffix "xxx.xxx.xxx/nn".

```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination    
    0     0 TEST       all  --  *      *       192.168.100.10       0.0.0.0/0           
    0     0 TEST       all  --  *      *       0.0.0.0/0            192.168.100.10       state RELATED,ESTABLISHED
```

### Example

The content of the file to be created would look like this for network-wide configuration:

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

If you want to be even more precise and define special areas in the network, you can do this with the network calculator from Heise.de. https://www.heise.de/netze/tools/netzwerkrechner/

## Create the rules

Every firewall should be set by default to block any communication that is not explicitly allowed. You can control this setting in firewall.conf. This variable defines the default state of your firewall: ``` DEFAULT_STATUS="DROP" ```.

Let's assume your firewall is to be installed on the Internet router and is to control the communication of your network devices at home with the Internet. The IP addresses are obtained from a DHCP server within your network, the IP address range is 192.168.104.0/24, which corresponds to 253 (*1) available IP addresses with the subnet mask 255.255.255.0.

(*1) One IP address has already been deducted because the router has this as a fixed IP)

### Preliminary considerations

You have *n* different clients with the following IP addresses:

* 192.168.100.1 (Router)
* 192.168.100.5 (Mobiltelefon A)
* 192.168.100.7 (Fernseher)
* 192.168.100.8 (Notebook)
* 192.168.100.9 (Tablet)
* 192.168.100.10 (Mobiltelefon B)
* 192.168.100.12 (Computer)
* 192.168.100.14 (Smart-Home)

First you have to find out which communication which device really needs urgently. Because not every communication is desired. Last but not least, you can force the devices within your network to use your own services.

#### Ports/TCP that are always needed:

* 80 HTTP
* 443 HTTPS

These ports should actually be enabled for every device that always needs internet access. Only the Smart Home system and the tablet used to control the Smart Home should not be allowed to access the Internet. For one thing, you don't want to be monitored and you don't want the devices to make unauthorised phone calls home.

#### Additionally required ports/TCP

A list of standardised ports can be found here: https://de.wikipedia.org/wiki/Liste_der_standardisierten_Ports

Mail server access: (Please check with your mail server provider which ports are actually required)

* 25 (SMTP)
* 110 (POP3)
* 143 (IMAP)
* 465 (SSL SMTP)
* 587 (TLS SMTP)
* 993 (SSL IMAP)
* 995 (SSL POP3)

additional ports/TCP

* 53 (DNS)*
* 5060 (VoIP)

additional ports/UDP

* 53 (DNS)*
* 123 (NTP)*
* 5060 (VoIP)

Actually, it is not necessary to include other ports in your releases. In any case, you should consider the ports marked with *. Providers like to use the log files of the servers to draw conclusions about internet use and the number of devices in the network. You should think about whether DNS queries should at least be allowed only to the internal router. Unfortunately, very few routers have an NTP server so that you can use time synchronisation via it.

### Devices that should only remain in the internal network

Setting up a new firewall rule is very simple. There are two different network interfaces

1. ppp0 -> the internet connection with the public IP address
2. eth0 -> the internal interface

Both interfaces should be defined in firewall.conf to DEV_EXTERN (ppp0) and DEV_INTERN (eth0).

* ``` $FW ``` -> Variable mit dem Programmnamen ``` iptables ```
* ``` -A ```
* ``` $rulename ``` -> Variable mit dem im Script vergebenen Namen der Firewall-Regel, damit die Regel auch dahin gesetzt wird, wo sie sein soll
* ``` -i ``` -> Input-Device (Netzwerkschnittstelle
* ``` $DEV_INTERN ``` -> die aus der firewall.conf bezogene Eintrag zur internen Netzwerkschnittstelle
* ``` -o ``` -> Output-Device (Netzwerkschnittstelle)
* ``` $DEV_INTERN ``` -> die aus der firewall.conf bezogene Eintrag zur internen Netzwerkschnittstelle
* ``` -j ```
* ``` ACCEPT ``` -> Diese Regel darf

Put together, the rule then looks like this:

``` $FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -j ACCEPT  ## nach Intern darf kommuniziert werden ```

## Allow HTTP and HTTPS

* ``` $FW ``` -> variable with the programme name ``` iptables ```
* ``` -A ```
* ``` $rulename ``` -> Variable with the name of the firewall rule given in the script, so that the rule is set where it should be.
* ``` -i ``` -> Input device (network interface)
* ``` $DEV_INTERN ``` -> the entry for the internal network interface taken from firewall.conf
* ``` -o ``` -> output device (network interface)
* $DEV_EXTERN ``` -> the entry for the external network interface taken from firewall.conf.

Up to this point, every single network device is allowed to access the Internet. This is exactly what we want to prevent and control, which is why it requires further entries:

* ``` -s ``` -> network source as IP address of the client
* 192.168.100.8 ``` -> the IP address of the client to which this rule is explicitly assigned.

With this entry, the notebook should now be able to communicate with the internet without restrictions, all other devices should not. However, we do not want to allow all communication, which is why the following entries are important.

* ``` -p tcp ``` -> Protocol TCP

From here on, all packets except TCP would be blocked. But this is not enough.

* ```` -m multiport ``` -> we want to specify several TCP ports.
* ``` --dport ``` -> destination port, i.e. the destination to be reached
* ``` 80,443 ``` -> the ports for HTTP and HTTPS

Finalising the rule

* ``` -j ```
* ``` ACCEPT ``` -> This rule is not allowed to be used.

The rule now looks like this:

``` $FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.100.8 -p tcp -m multiport --dport 80,443 -j ACCEPT  ## The notebook may access the Internet ```
