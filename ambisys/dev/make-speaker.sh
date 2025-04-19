#!/bin/sh

NUM=$1

STYLE=""
SPK="";

echo "nfcon = 1;"
echo "L = 3;"
echo "N = ${NUM};"

for M in $(seq $NUM); do
    N=$(( M - 1 ));
    echo "speaker($N) = (nentry(\"v:speaker/h:${SPK}$N/x${STYLE}\",0,-50,50,0.1),nentry(\"v:speaker/h:${SPK}$N/y${STYLE}\",0,-50,50,0.1),nentry(\"v:speaker/h:${SPK}$N/z${STYLE}\",0,-50,50,0.1));"
done
