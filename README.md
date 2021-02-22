# GrafanaWorkLog

1. Enabled XMRig HTTP API on PAC
2. Installed Ubuntu 20.04 on Hyper-V (1.155)
3. Installed InfluxDB & created 'rigs' db
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
