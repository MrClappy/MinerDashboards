#!/bin/bash

json=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer token" http://<IP>:<PORT>/1/summary)

hashrate=$(echo $json | jq -r '.hashrate.total[0]')
workerid=$(echo $json | jq -r '.worker_id')
algo=$(echo $json | jq -r '.algo')
uptime=$(echo $json | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=rigs' --data-binary "xmrigs,rig=$workerid,algo=$algo uptime=$uptime,hashrate=$hashrate"
