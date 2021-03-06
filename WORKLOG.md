# Dashboard Work Log

## Metric Logging

1. Enabled XMRig HTTP API on miners and proxy
2. Installed Telegraf on miners
3. Installed CoreTemp on miners
4. Installed CoreTempTelegraf on miners
5. Enabled global shared memory & run on startup on CoreTemp on miners
7. Configured Telegraf to dump to InfluxDB (telegraf)

```
[[inputs.exec]]
   commands = [
      'powershell -Command "C:\CoreTempTelegraf"'
   ]
   data_format = "influx"
```

8. Configured Telegraf as Windows service on miners
9. Created Scheduled Task to run Monero Wallet RPC Server on Startup:

```
monero-wallet-rpc.exe --wallet-file <WALLET_FILE> --rpc-bind-port <PORT> --daemon-address <IP>:<PORT> --password <PASSWORD> --rpc-bind-ip 0.0.0.0 --confirm-external-bind --disable-rpc-login
```
## Metric Scraping

1. Created bash to pull data from XMRig API & dump to InfluxDB (rigs)

```shell
#!/bin/bash

getstatistics=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" http://<IP>:<PORT>/1/summary)

hashrate=$(echo $getstatistics | jq -r '.hashrate.total[0]')
workerid=$(echo $getstatistics | jq -r '.worker_id')
algo=$(echo $getstatistics | jq -r '.algo')
uptime=$(echo $getstatistics | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=rigs' --data-binary "xmrigs,rig=$workerid,algo=$algo uptime=$uptime,hashrate=$hashrate"
```

2. Created bash to pull data from proxy API / pool API & dump to InfluxDB (proxy)

```shell
#!/bin/bash

getproxy=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" http://<IP>:<PORT>/1/summary)
gethashrate=$(curl https://api.moneroocean.stream/miner/<WALLET_ID>/chart/hashrate)

hashrate=$(echo $gethashrate | jq '.[0].hs2')
miners=$(echo $getproxy | jq -r '.miners.now')
uptime=$(echo $getproxy | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=proxy' --data-binary "statistics hashrate=$hashrate,minercount=$miners,uptime=$uptime"
```

3. Created bash to pull data from pool API & dump to InfluxDB (mo)

```shell
#!/bin/bash

gethashrate=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/pool/stats)
getpayments=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/miner/<ADDRESS>/payments)
getdue=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/miner/<ADDRESS>/stats)

hashrate=$(echo $gethashrate | jq '.pool_statistics.hashRate')
lastpayment=$(echo $getpayments | jq '.[0].ts')

now=$(date +%s)
timediff=(`expr $now - $lastpayment`)
gotdue=$(echo $getdue | jq '.amtDue')

adj=0.0
adj2=0.00

if [ ${#gotdue} -eq 11 ]; then amtdue=$(echo $adj$gotdue)
else amtdue=$(echo $adj2$gotdue)
fi

curl -i -XPOST 'http://<IP>:<PORT>/write?db=mo' --data-binary "statistics,rig=MO hashrate=$hashrate,payment=$timediff,due=$amtdue"
```

4. Created bash to pull data from Wemo & dump to InfluxDB (power)

```shell
#!/bin/bash

getpower=$(curl -H 'Content-type:text/xml;  charset=utf-8' -H 'SOAPACTION:"urn:Belkin:service:insight:1#GetInsightParams"' -d '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetInsightParams xmlns:u="urn:Belkin:service:insight:1"></u:GetInsightParams></s:Body></s:Envelope>' 'http://<IP>:49153/upnp/control/insight1')

power=$(echo $getpower | cut -d'|' -f8)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=power' --data-binary "power value=$power"
```

5. Created bash to pull data from CoinMarketCap API & dump to InfluxDB (xmrprice)

```shell
#!/bin/bash

getstatistics=$(curl -X GET -H "X-CMC_PRO_API_KEY: <API_KEY>" -H "Accept: application/json" -d "symbol=XMR" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)

price=$(echo $getstatistics | jq '.data.XMR.quote.USD.price')
change=$(echo $getstatistics | jq '.data.XMR.quote.USD.percent_change_24h')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=xmrprice' --data-binary "price value=$price,change=$change"
```

6. Created bash to pull data from Monero Wallet RPC server (balance)

```shell
#!/bin/bash

getbalance=$(curl http://<IP>:<PORT>/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,1]}}' -H 'Content-Type: application/json')

gotbalance=$(echo $getbalance | jq -r '.result.balance')
balance=$(echo "$gotbalance * 0.000000000001" | bc)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=balance' --data-binary "balance,rig=Wallet balance=$balance"
```

## Database & Dashboards

1. Installed Ubuntu 20.04 on Hyper-V
2. Created cron jobs to run each bash script every minute
3. Installed InfluxDB & created databases: rigs, telegraf, xmrprice, power, proxy, mo, balance
4. Installed Grafana & added databases as InfluxDB Input Sources: rigs, telegraf, xmrprice, power, proxy, mo, balance
5. Added queries to Grafana Dashboard:

- Get Hash Rate: (proxy) SELECT mean("hashrate") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get CPU Temp: (telegraf) SELECT "temperature" FROM "coretemp_cpu" WHERE ("host" = '<MINER_NAME>') AND $timeFilter
- Get Current Algo: (rigs) SELECT * FROM "xmrigs" WHERE ("rig" = '<MINER_NAME>') AND $timeFilter
- Get Farm Wattage: (power) SELECT last("value") FROM "power" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Proxy Uptime: (proxy) SELECT last("uptime") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Pool Hash Rate: (mo) SELECT mean("hashrate") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Current XMR Price: (xmrprice) SELECT mean("value") FROM "price" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Day Price Change: (xmrprice) SELECT mean("change") FROM "price" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Last Payment: (mo) SELECT mean("payment") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Currently Due: (mo) SELECT last("due") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
- Get Wallet Balance: (balance) SELECT last("balance") FROM "balance" WHERE $timeFilter GROUP BY time($__interval) fill(null)

## References

- MoneroOcean API: https://github.com/MoneroOcean/nodejs-pool/blob/master/lib/api.js
- CoinMarketCap API: https://coinmarketcap.com/api/documentation/v1/
- Telegraf Windows Service: https://docs.influxdata.com/telegraf/v1.17/administration/windows_service/
- CoreTempTelegraf: https://tomk.xyz/k/coretemptelegraf
- Monero Wallet RPC: https://www.getmonero.org/resources/developer-guides/wallet-rpc.html

## Donations

If you find this information helpful, donations are greatly appreciated!

XMR: 47zEuqnGse6LBQMF9hnRGxGn7bLgJQXzZThjqFMFsqb152PVmiPP5eXfK7vNPpQTX5W5BmAqqu6DeVdUrT7nG5NyMNxvMr2
