#!/bin/bash
#Miner1Metrics.sh

# Optional GMiner Support
# GMiner=`python3 <PATH>/GMiner.py`
# c=0
# for metric in ${GMiner}; do
#     eval "var$c=$metric";
#    c=$((c+1));
# done

# Algo=$(echo $var0)
# HashRate=$(echo $var1)
# UpTime=$(echo $var3)

MinerStats=$(curl -X GET -H "Content-Type: application/json" http://<IP>:<PORT>/1/summary)

HashRate=$(echo $MinerStats | jq -r '.hashrate.total[0]')
Miner=$(echo $MinerStats | jq -r '.worker_id')
Algo=$(echo $MinerStats | jq -r '.algo')
UpTime=$(echo $MinerStats | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "MinerMetrics,Miner=$Miner,Algo=$Algo UpTime=$UpTime,HashRate=$HashRate"
