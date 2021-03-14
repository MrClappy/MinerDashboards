#!/bin/bash
#PowerMetrics.sh

PowerDraw=$(curl -H 'Content-type:text/xml;  charset=utf-8' -H 'SOAPACTION:"urn:Belkin:service:insight:1#GetInsightParams"' -d '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetInsightParams xmlns:u="urn:Belkin:service:insight:1"></u:GetInsightParams></s:Body></s:Envelope>' 'http://<IP>:49153/upnp/control/insight1')

PowerDraw=$(echo $PowerDraw | cut -d'|' -f8)

curl -i -XPOST 'http://<IP>:<PORT>/write?db=MoneroMetrics' --data-binary "PowerDraw PowerDraw=$PowerDraw"
