#!/bin/bash

## print header lines
shopt -s extglob
echo "["
count=0
con_count=0
while IFS= read -r line; do
    ## test line contenst and parse as required

    [[ "$line" =~ \(Channel ]] && { chn=${line##*nel }; chn=${chn:0:$((${#chn}-1))}; }
    [[ "$line" =~ Frequen ]] && { freq=${line##*ncy:}; freq=${freq%% *}; }
    [[ "$line" =~ Quality ]] && {
        qual=${line##*ity=}
        qual=${qual%% *}
        lvl=${line##*evel=}
        lvl=${lvl%% *}
    }
    [[ "$line" =~ Encrypt ]] && enc=${line##*key:}
    [[ "$line" =~ ESSID ]] && {
        essid=${line##*ID:}
        count=$count+1
    }
    [[ "$line" =~ Mode ]] && mode=${line##*de:}
    if [[ ${line##*( )} =~ ^"IE: WPA".* ]]
    then
        sec=${line##*Version }
        if [ -n "$sec" ]
           then
             security="WPA1"
        fi
    fi
    if [[ ${line##*( )} =~ ^"IE:".* ]] &&  [[ $line =~ WPA2 ]]
      then
      security="WPA2"
    fi
    [[ "$line" =~ Cell ]] && {
    if ((count > 0 ))
     then
        echo "{"
        echo "\"essid\":$essid,"
        echo "\"macAddress\":\"$mac\","
        echo "\"signalQuality\":\"$qual\","
        echo "\"signalLevel\":\"$lvl\","
        echo "\"securityType\":\"$security\","
        echo "\"encryption\":\"$enc\","
        echo "\"channel\":\"$chn\","
        echo "\"frequency\":\"$freq\","
        echo "\"mode\":\"$mode\""
        printf "}"
        con_count=$con_count+1
   fi
   }
   [[ "$line" =~ Address ]] && mac=${line##*ss:}
done
    if ((con_count < count))
        then
        if ((count > 1))
           then
             printf ",\n"
        fi
        echo "{"
        echo "\"essid\":$essid,"
        echo "\"macAddress\":\"$mac\","
        echo "\"signalQuality\":\"$qual\","
        echo "\"signalLevel\":\"$lvl\","
        echo "\"securityType\":\"$security\","
        echo "\"encryption\":\"$enc\","
        echo "\"channel\":\"$chn\","
        echo "\"frequency\":\"$freq\","
        echo "\"mode\":\"$mode\""
        printf "}"
    fi
echo "]"

shopt -u extglob
