#!/bin/sh

prevState=""
currState=""

setEthernetInterfaceConfigState () {
   if [ ! -e /var/lib/chaibio ]
   then
      mkdir -p /var/lib/chaibio
   fi

   if [ ! -e /var/lib/chaibio/prevstate_of_ethernet_config ]
   then
      touch /var/lib/chaibio/prevstate_of_ethernet_config
   fi
   
   if [ ! -e /etc/network/interfaces ]
   then
      exit 1
   fi

   if grep -q "iface eth0 inet static" /etc/network/interfaces;
   then
      echo "The interface eth0 configured as static IP"
      prevState=`cat /var/lib/chaibio/prevstate_of_ethernet_config`
      #if [ "$prevState" = "" ]
      #then
      #   echo "static" > /var/lib/chaibio/prevstate_of_ethernet_config
      #fi
      currState="static"
   else
      echo "The interface eth0 configured as dynamic IP"
      prevState=`cat /var/lib/chaibio/prevstate_of_ethernet_config`
      #if [ "$prevState" = "" ]
      #then
      #   echo "dhcp" > /var/lib/chaibio/prevstate_of_ethernet_config
      #fi
      currState="dhcp"
   fi
}

if [ "$IFACE" = "eth0" ]
then
   echo "Check the ethernet interface state"
   if [ $(cat /sys/class/net/eth0/operstate) = "up" ]
   then
      echo "Ethernet interface is already up"
      echo "Check whether device is changed to Dynamic IP via DHCP"
      setEthernetInterfaceConfigState
      if [ "$prevState" = "static" ] && [ "$currState" = "dhcp" ]
      then
         echo "State changed, Set the previous state to $currState"
         echo "dhcp" > /var/lib/chaibio/prevstate_of_ethernet_config
         ip addr flush dev eth0 && ifup eth0
      elif [ "$prevState" = "dhcp" ] && [ "$currState" = "static" ]
      then
         echo "State changed, Set the previous state to $currState"
         echo "static" > /var/lib/chaibio/prevstate_of_ethernet_config
      fi
   else
      #sleep 5
      ifup eth0
   fi
fi
