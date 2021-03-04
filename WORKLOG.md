# Dashboard Work Log

1. Enabled XMRig HTTP API on miners and proxy
3. Installed Ubuntu 20.04 on Hyper-V (1.155)
4. Installed InfluxDB created DBs: rigs, telegraf, xmrprice, power, proxy, mo
5. Created bash to pull data from XMRig API & dump to InfluxDB (rigs)

```shell
#!/bin/bash

json=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer token" http://<IP>:<PORT>/1/summary)

hashrate=$(echo $json | jq -r '.hashrate.total[0]')
workerid=$(echo $json | jq -r '.worker_id')
algo=$(echo $json | jq -r '.algo')
uptime=$(echo $json | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=rigs' --data-binary "xmrigs,rig=$workerid,algo=$algo uptime=$uptime,hashrate=$hashrate"
```
6. Created bash to pull data from proxy API / pool API & dump to InfluxDB (proxy)

```shell
#!/bin/bash

getproxy=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer token" http://<IP>:<PORT>/1/summary)
gethash=$(curl https://api.moneroocean.stream/miner/<WALLET_ID>/chart/hashrate)

hashrate=$(echo $gethash | jq '.[0].hs2')
miners=$(echo $getproxy | jq -r '.miners.now')
uptime=$(echo $getproxy | jq -r '.uptime')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=proxy' --data-binary "statistics hashrate=$hashrate,minercount=$miners,uptime=$uptime"
```

7. Created bash to pull data from pool API & dump to InfluxDB (mo)

```shell
#!/bin/bash

json=$(curl -X GET -H "Content-Type: application/json" https://api.moneroocean.stream/pool/stats)

getpayments=$(curl https://api.moneroocean.stream/miner/<WALLET_ID>/payments)

lastpayment=$(echo $getpayments | jq '.[0].ts')
now=$(date +%s)
timediff=(`expr $now - $lastpayment`)

hashRate=$(echo $json | jq '.pool_statistics.hashRate')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=mo' --data-binary "statistics,rig=MO hashrate=$hashRate,payment=$timediff"
```

8. Created bash to pull data from Wemo & dump to InfluxDB (power)


```shell
#!/bin/bash

json=$(curl -H 'Content-type:text/xml;  charset=utf-8' -H 'SOAPACTION:"urn:Belkin:service:insight:1#GetInsightParams"' -d '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetInsightParams xmlns:u="urn:Belkin:service:insight:1"></u:GetInsightParams></s:Body></s:Envelope>' 'http://<IP>:49153/upnp/control/insight1')

power=$(echo $json | cut -d'|' -f8)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=power' --data-binary "power value=$power"
```

9. Created bash to pull data from CoinMarketCap API & dump to InfluxDB (xmrprice)

```shell
#!/bin/bash

json=$(curl -X GET -H "X-CMC_PRO_API_KEY: <API_KEY>" -H "Accept: application/json" -d "symbol=XMR" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)

price=$(echo $json | jq '.data.XMR.quote.USD.price')
change=$(echo $json | jq '.data.XMR.quote.USD.percent_change_24h')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=xmrprice' --data-binary "price value=$price,change=$change"
```

10. Created cron jobs to run each bash script every minute
11. Installed Telegraf on miners
12. Installed CoreTempTelegraf on miners
13. Installed CoreTemp on miners
14. Enabled global shared memory on CoreTemp on miners
15. Configured CoreTemp to run on start on miners
17. Configured Telegraf to dump to InfluxDB (telegraf)
18. Configured Telegraf as Windows service on miners
19. Installed Grafana on Ubuntu VM
20. Added queries:

_Get Hash Rate: (proxy) SELECT mean("hashrate") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get CPU Temp: (telegraf) SELECT "temperature" FROM "coretemp_cpu" WHERE ("host" = '<MINER_NAME>') AND $timeFilter
Get Current Algo: (rigs) SELECT * FROM "xmrigs" WHERE ("rig" = '<MINER_NAME>') AND $timeFilter
Get Farm Wattage: (power) SELECT last("value") FROM "power" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get Proxy Uptime: (proxy) SELECT last("uptime") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get Pool Hash Rate: (mo) SELECT mean("hashrate") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get Current XMR Price: (xmrprice) SELECT mean("value") FROM "price" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get Day Price Change: (xmrprice) SELECT mean("change") FROM "price" WHERE $timeFilter GROUP BY time($__interval) fill(null)
Get Last Payment: (mo) SELECT mean("payment") FROM "statistics" WHERE $timeFilter GROUP BY time($__interval) fill(null)_

References:

MoneroOcean API: https://github.com/MoneroOcean/nodejs-pool/blob/master/lib/api.js
CoinMarketCap API: https://coinmarketcap.com/api/documentation/v1/
Telegraf Windows Service: https://docs.influxdata.com/telegraf/v1.17/administration/windows_service/
CoreTempTelegraf: https://tomk.xyz/k/coretemptelegraf

Future References:

https://www.getmonero.org/resources/developer-guides/wallet-rpc.html
