#!/bin/bash

shopt -s extglob
if [[ $1 == "-a" ]]; then
  while IFS= read -r line; do
    ## test line contents and parse as required

    [[ "$line" =~ freq ]] && wfreq=${line##*req: }

    [[ "$line" =~ RX ]] && {
        RXline=${line##*RX: }
        RXbytes=${RXline%% *}
        RXpackets=${RXline##*bytes (}
        RXpackets=${RXpackets%% *}
    }
    [[ "$line" =~ SSID ]] && {
        ssid=${line##*ID: }
    }
    [[ "$line" =~ TX ]] && {
        TXline=${line##*TX: }
        TXbytes=${TXline%% *}
        TXpackets=${TXline##*bytes (}
        TXpackets=${TXpackets%% *}
    }

    [[ "$line" =~ signal ]] && {
        qual=${line##*ignal: }
        qual=${qual%% *}
    }
    [[ "$line" =~ Connected ]] && {
        mac=${line##*ected to }
        mac=${mac%% *}
    }

  done
  if [ -z "$mac" ]; then
          echo "0"
  else
  	  echo "{"
  	  echo "\"essid\":\"$ssid\","
	  echo "\"macAddress\":\"$mac\","
	  echo "\"signalQuality\":\"$qual\","
	  echo "\"RXBytes\":\"$RXbytes\","
	  echo "\"RXPackets\":\"$RXpackets\","
	  echo "\"TXBytes\":\"$TXbytes\","
	  echo "\"TXPackets\":\"$TXpackets\","
	  echo "\"frequency\":\"$wfreq\","
	  printf "}\n"
  fi

else

   while IFS= read -r line; do
      [[ "$line" =~ Connected ]] && {
         mac=${line##*ected to }
         mac=${mac%% *}
      }

   done
   if [ -z "$mac" ]
      then
          echo "0"
      else
          echo "1"
   fi

fi

shopt -u extglob

