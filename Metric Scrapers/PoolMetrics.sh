#!/bin/bash
#PoolMetrics.sh

PoolHashRate=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/pool/stats)
MinerHashRate=$(curl https://api.moneroocean.stream/miner/<ADDRESS>/chart/hashrate)
LastPayment=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/miner/<ADDRESS>/payments)
AmountDue=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/miner/<ADDRESS>/stats)

PoolHashRate=$(echo $PoolHashRate | jq '.pool_statistics.hashRate')
MinerHashRate=$(echo $MinerHashRate | jq '.[0].hs2')
LastPayment=$(echo $LastPayment | jq '.[0].ts')

Now=$(date +%s)
LastPayment=(`expr $Now - $LastPayment`)

AmountDue=$(echo $AmountDue | jq '.amtDue')

adj1=0.0
adj2=0.00

if [ ${#AmountDue} -eq 11 ]; then AmountDue=$(echo $adj1$AmountDue)
else AmountDue=$(echo $adj2$AmountDue)
fi

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "PoolMetrics,Pool=MoneroOcean PoolHashRate=$PoolHashRate,MinerHashRate=$MinerHashRate,LastPayment=$LastPayment,AmountDue=$AmountDue"
