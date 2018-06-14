# TP-Link HS100/HS110 SmartPlug next step scripts and programs

This repository is a follow up to the
[TP-Link HS100/HS110 SmartPlug basic on/off scripts/programs](https://github.com/andycranston/hs100110-basics)
repository.  It has some extra stuff that show how to leverage the use of TP-Link SmartPLugs.

## The simple JSON string formatter command "jfmt"

While running:

```
hs100110 -h 192.168.1.65 -query
```

provides query response JSON string from a SmartPlug similar to:

```
{"system":{"get_sysinfo":{"err_code":0,"sw_ver":"1.2.5 Build 171213 Rel
.095335","hw_ver":"1.0","type":"IOT.SMARTPLUGSWITCH","model":"HS110(UK)
","mac":"50:C7:BF:5B:0D:56","deviceId":"80061F21F93C97CCF2136449B397E93
71878595B","hwId":"2448AB56FB7E126DE5CF876F84C6DEB5","fwId":"0000000000
0000000000000000000000","oemId":"90AEEA7AECBF1A879FCA3C104C58C4D8","ali
as":"IP: 86.133.159.133","dev_name":"Wi-Fi Smart Plug With Energy Monit
oring","icon_hash":"","relay_state":0,"on_time":0,"active_mode":"schedu
le","feature":"TIM:ENE","updating":0,"rssi":-59,"led_off":0,"latitude":
55.041531,"longitude":-6.951144}}}
```

it is hard to parse from a script and you are usually only interested
on one specific attribute.

Here is where the simple JSON string formatter command "jfmt" comes in handy.
Running:

```
hs100110 -h 192.168.1.65 -query | jfmt
```

gives a far nicer output:

```
"err_code":0
"sw_ver":"1.2.5 Build 171213 Rel.095335"
"hw_ver":"1.0"
"type":"IOT.SMARTPLUGSWITCH"
"model":"HS110(UK)"
"mac":"50:C7:BF:5B:0D:56"
"deviceId":"80061F21F93C97CCF2136449B397E9371878595B"
"hwId":"2448AB56FB7E126DE5CF876F84C6DEB5"
"fwId":"00000000000000000000000000000000"
"oemId":"90AEEA7AECBF1A879FCA3C104C58C4D8"
"alias":"IP: 86.133.159.133"
"dev_name":"Wi-Fi Smart Plug With Energy Monitoring"
"icon_hash":""
"relay_state":0
"on_time":0
"active_mode":"schedule"
"feature":"TIM:ENE"
"updating":0
"rssi":-60
"led_off":0
"latitude":55.041531
"longitude":-6.951144
```

and suppling an attribute name:

```
hs100110 -h 192.168.1.65 -query | jfmt '"mac"'
```

is even better giving just:

```
"50:C7:BF:5B:0D:56"
```

You can use this technique in a shell script as follows:

```
mode=`hs100110 -h 192.168.1.65 -query | jfmt '"active_mode"'
if [ "$mode" == '"schedule"' ]
then
  echo "Plug is in schedule mode"
fi
```

### Compiling jfmt

The jfmt command is created from a lex specification and a very simple
yacc grammar in the files `jfmt.lex` and `jfmt.yacc` respectively.
To compile do something similar to:

```
yacc -d jfmt.yacc
lex jfmt.lex
gcc -o jfmt lex.yy.c y.tab.c
cp jfmt $HOME/bin
chmod a+x $HOME/bin
```

Note that jfmt is not a full featured JSON string parser by any means.  As
it stands it works with the query output from the TP-Link HS100 and HS110
SmartPLugs.  As a warning future firmware upgrades to the plugs might
produce output that the jfmt command cannot handle.

## The duclient Dynamic DNS reporter

Because it is now easy to query the status of a specific attribute
of a smartplug and easy to set an atttibute I figured I could use the
facility on the Kasa mobile app to set a specific name of a plug, have
some software on my home network query the name and respond by setting
a new name.

The query string I selected is `getip` for get my external IP address
and the response should be my current external IP address.  Being able
to do this on the Kasa app on my smart phone means I can find out the
current external IP address while away from home and use this to access
hosts on my home network remotely.

Here is how it works:

```
Get the alias name of a SmartPlug
if the alias name is "getip" then do the following:
    get my external IP address
    set the alias name of the plug to "IP:" followed by the external IP address
wait one minute
do everything again
```

The guts of it all is in the shell script `duclient.sh`.  I copy this
to my binary subdirectory (losing the ".sh" file name suffix):

```
cp duclient.sh $HOME/bin
cd $HOME/bin
mv duclient.sh duclient
chmod a+x duclient
```

In order for the script to run every minute I make use of cron with the
following entry:

```
* * * * * /home/andyc/bin/duclient 192.168.1.65
```

Change the IP address to your plug as necessary.

The script determines my external IP address using the curl command
with the following arguments:

```
curl -s ifconfig.co
```

So to recap you will need the following:

* hs100110 command in $HOME/bin
* the curl command must be installed
* the jfmt command in $HOME/bin
* the duclient script in $HOME/bin
* and entry in your crontab with the correct SmartPlug IP address

But wait you might say!  That is a lot of effort because you could just
use a free Dynamic DNS update client from one of the many free
providers like:

* [Oracle Dyn’s Managed DNS](https://dyn.com/)
* [DNS Dynamic](https://www.dnsdynamic.org/)
* [No-IP](https://www.noip.com/)

Certainly.  And I recommend you do as that is what I do.  The duclient
script is really a backup but one that has saved my situation out on
the road more than once.

It is also a demo of using the SmartPlug for something it probably was
not originally intended for.

Infact if you look at the script you will see it responds to other
"command names" like "uptime".

I find the uptime useful as it is a way to detect when I am away from
home if there has been a power cut.  I live in a rural location where
power outages are common and it is handy to know when they hapen.

You can easily extend the script to act on command names
of your own.  What you can do is only really limited by
your imagination.




--------------------
End of README
