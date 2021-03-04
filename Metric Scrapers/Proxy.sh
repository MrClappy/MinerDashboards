#!/bin/bash

getproxy=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer token" http://<IP>:<PORT>/1/summary)
gethash=$(curl https://api.moneroocean.stream/miner/<WALLET_ID>/chart/hashrate)

hashrate=$(echo $gethash | jq '.[0].hs2')
miners=$(echo $getproxy | jq -r '.miners.now')
uptime=$(echo $getproxy | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=proxy' --data-binary "statistics hashrate=$hashrate,minercount=$miners,uptime=$uptime"
