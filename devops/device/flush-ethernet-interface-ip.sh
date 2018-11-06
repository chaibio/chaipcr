#!/bin/sh

if [ "$IFACE" = "eth0" ]
then
   ip addr flush dev eth0
fi
