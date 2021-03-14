#!/bin/bash
#XMRValue.sh

XMRMetrics=$(curl -X GET -H "X-CMC_PRO_API_KEY: <API_KEY>" -H "Accept: application/json" -d "symbol=XMR" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)

XMRValue=$(echo $XMRMetrics | jq '.data.XMR.quote.USD.price')
DayChange=$(echo $XMRMetrics | jq '.data.XMR.quote.USD.percent_change_24h')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "XMRValue XMRValue=$XMRValue,DayChange=$DayChange"
