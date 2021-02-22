# GrafanaWorkLog

1. Enabled XMRig HTTP API on PAC
2. Installed Ubuntu 20.04 on Hyper-V (1.155)
3. Installed InfluxDB created 'rigs' db
4. Created '/root/PAC.sh' to pull data & dump to InfluxDB

```bash 
#!/bin/bash
#collect data from API
json=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer token" http://192.168.1.154:9999/1/summary)
#extract hashrate, worker_id, currency
hashrate=$(echo $json | jq -r '.hashrate.total[0]')
workerid=$(echo $json | jq -r '.worker_id')
currency=$(echo $json | jq -r '.algo')
#store in db
curl -i -XPOST 'http://localhost:8086/write?db=rigs' --data-binary "xmrigs,rig=$workerid,currency=$currency value=$hashrate"
```

5. Created cron job to get value every minute (crontab -e)
6. Installed Grafana
7. Added InfluxDB input source
8. Added basic graph: SELECT moving_average("value", 10) FROM "xmrigs" WHERE $timeFilter
9. Installed Telegraf on PAC
10. Installed CoreTempTelegraf (https://tomk.xyz/k/coretemptelegraf) on PAC
11. Configured Telegraf to dump to InfluxDB 'telegraf' dp
12. Added graph: SELECT moving_average("temperature", 10) FROM "coretemp_cpu" WHERE ("host" = 'PAC') AND $timeFilter
13. Added graph: SELECT distinct("value")  / 1000 FROM "xmrigs" WHERE $timeFilter GROUP BY time($__interval) fill(null)
14. Added graph: SELECT last("uptime")  / 3600 FROM "xmrigs" WHERE ("rig" = 'PAC') AND $timeFilter
