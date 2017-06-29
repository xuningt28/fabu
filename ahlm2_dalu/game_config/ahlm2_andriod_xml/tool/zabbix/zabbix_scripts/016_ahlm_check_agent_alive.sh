#!/bin/sh

targetAdr="10.11.2.249"

result=$(fping -a $targetAdr -r 2 -t 1000)
if [ "$result" = $targetAdr ]; then
    echo "1"
else
    echo "0"
fi 
