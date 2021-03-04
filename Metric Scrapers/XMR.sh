#!/bin/bash

json=$(curl -X GET -H "X-CMC_PRO_API_KEY: <API_KEY>" -H "Accept: application/json" -d "symbol=XMR" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest)

price=$(echo $json | jq '.data.XMR.quote.USD.price')
change=$(echo $json | jq '.data.XMR.quote.USD.percent_change_24h')

curl -i -XPOST 'http://<IP>:<PORT>/write?db=xmrprice' --data-binary "price value=$price,change=$change"
