#!/bin/bash

json=$(curl -X GET -H "Content-Type: application/json" http://192.168.1.100:9999/1/summary)

hashrate=$(echo $json | jq -r '.hashrate.total[0]')
workerid=$(echo $json | jq -r '.worker_id')
algo=$(echo $json | jq -r '.algo')
uptime=$(echo $json | jq -r '.uptime')

curl -i -XPOST 'http://localhost:8086/write?db=rigs' --data-binary "xmrigs,rig=$workerid,algo=$algo uptime=$uptime,hashrate=$hashrate"
