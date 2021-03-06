#!/bin/bash

gethashrate=$(curl https://api.moneroocean.stream/pool/stats)
getpayments=$(curl https://api.moneroocean.stream/miner/<ADDRESS>/payments)
getdue=$(curl https://api.moneroocean.stream/miner/<ADDRESS>/stats)

hashRate=$(echo $gethashrate | jq '.pool_statistics.hashRate')
lastpayment=$(echo $getpayments | jq '.[0].ts')

now=$(date +%s)
timediff=(`expr $now - $lastpayment`)
gotdue=$(echo $getdue | jq '.amtDue')

adj=0.0
adj2=0.00

if [ ${#gotdue} -eq 11 ]; then amtdue=$(echo $adj$gotdue)
else amtdue=$(echo $adj2$gotdue)
fi

curl -i -XPOST 'http://<IP>:<PORT>/write?db=mo' --data-binary "statistics,rig=MO hashrate=$hashRate,payment=$timediff,due=$amtdue"
