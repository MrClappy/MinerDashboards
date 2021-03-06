getbalance=$(curl http://<IP>:<PORT>/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_balance","params":{"account_index":0,"address_indices":[0,1]}}' -H 'Content-Type: application/json')

gotbalance=$(echo $getbalance | jq -r '.result.balance')
balance=$(echo "$gotbalance * 0.000000000001" | bc)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=balance' --data-binary "balance,rig=Wallet balance=$balance"
