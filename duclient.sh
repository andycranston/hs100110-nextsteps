#! /bin/sh
#
# @(!--#) @(#) duclient.sh, version 002, 02-june-2018
#
# Dynamic DNS Update Client based on a TP-LINK HS100 or HS110 Wifi plug
#

#
# function: getalias
#

getalias()
{
  hs100110 -h $1 2>/dev/null | jfmt '"alias"'
}

#
# function: setalias
#

setalias()
{
  hs100110 -h $1 -j '{"system":{"set_dev_alias":{"alias":"'"$2"'"}}}' >/dev/null 2>&1
}

#
# Main
#

PATH=/bin:/usr/bin:$HOME/bin
export PATH

progname=`basename $0`

if [ $# -eq 0 ]
then
  PLUGIP=192.168.1.109
else
  PLUGIP=$1
fi

aliastext=`getalias $PLUGIP | tr '[A-Z]' '[a-z]'`

case "$aliastext" in
  "\"getip\"")
    externalip=`curl -s ifconfig.co`
    ### externalip=`fudgeip $externalip`
    setalias $PLUGIP "IP: $externalip"
    ;;
  "\"uptime\"")
    uptime=`uptime -s | cut -c6-16`
    setalias $PLUGIP "UP: $uptime"
    ;;
  "\"reboot\"")
    setalias $PLUGIP "Rebooted"
    sudo -n /sbin/shutdown -r now
    ;;
  "\"date\"")
    datetext=`date '+%d %b - %H:%M'`
    setalias $PLUGIP "$datetext"
    ;;
esac

exit 0
