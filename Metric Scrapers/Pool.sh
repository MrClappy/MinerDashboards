#!/bin/bash

json=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/pool/stats)

getpayments=$(curl https://api.moneroocean.stream/miner/<WALLET_ID>/payments)

lastpayment=$(echo $getpayments | jq '.[0].ts')
now=$(date +%s)
timediff=(`expr $now - $lastpayment`)

hashRate=$(echo $json | jq '.pool_statistics.hashRate')

curl -i -XPOST 'http://localhost:8086/write?db=mo' --data-binary "statistics,rig=MO hashrate=$hashRate,payment=$timediff"
