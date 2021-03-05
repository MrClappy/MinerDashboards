#!/bin/bash

getstats=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/pool/stats)
getpayments=$(curl https://api.moneroocean.stream/miner/<ADDRESS>/payments)
getdue=$(curl https://api.moneroocean.stream/miner/<ADDRESS>/stats)

lastpayment=$(echo $getpayments | jq '.[0].ts')
now=$(date +%s)
timediff=(`expr $now - $lastpayment`)
gotdue=$(echo $getdue | jq '.amtDue')
adj=0.0
amtdue=$(echo $adj$gotdue)
hashRate=$(echo $getstats | jq '.pool_statistics.hashRate')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=mo' --data-binary "statistics,rig=MO hashrate=$hashRate,payment=$timediff,due=$amtdue"
