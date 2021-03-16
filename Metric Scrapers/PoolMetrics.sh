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

PreAmount=$(echo $AmountDue | jq '.amtDue')
AmountDue=$(printf %13s $PreAmount | tr ' ' 0 | sed 's/............$/.&/')

if [ -z "$LastPayment" ]; then 
LastPayment=0
fi

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "PoolMetrics,Pool=MoneroOcean PoolHashRate=$PoolHashRate,MinerHashRate=$MinerHashRate,LastPayment=$LastPayment,AmountDue=$AmountDue"
