#!/bin/bash
#WalletMetrics.sh

WalletBalance=$(curl http://<IP>:<PORT>/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,1]}}' -H 'Content-Type: application/json')

WalletBalance=$(echo $WalletBalance | jq -r '.result.balance')
WalletBalance=$(echo "$WalletBalance * 0.000000000001" | bc)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "WalletBalance,Coin=XMR WalletBalance=$WalletBalance"
