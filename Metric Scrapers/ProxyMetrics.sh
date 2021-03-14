#!/bin/bash
#ProxyMetrics.sh

ProxyStats=$(curl -X GET -H "Content-Type: application/json" http://<IP>:<PORT>/1/summary)

MinerCount=$(echo $ProxyStats | jq -r '.miners.now')
UpTime=$(echo $ProxyStats | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "ProxyMetrics MinerCount=$MinerCount,UpTime=$UpTime"
