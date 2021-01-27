#!/bin/bash
sublist=$(az account list | jq -c '.[] | {id, name}')

while IFS= read -r line; do
    subid=$(echo $line | jq -r '.id' 2>/dev/null)
    subname=$(echo $line | jq -r '.name' 2>/dev/null)

    iplist=$(az network public-ip list --subscription ${subid} --query 
'[?ipAddress!="None"].{name:name,id:id,ipAddress:ipAddress}' | jq -c 
'.[]')

    while IFS= read -r ip_line; do
        ip=$(echo $ip_line | jq -r '.ipAddress' 2>/dev/null)
        ipname=$(echo $ip_line | jq -r '.name' 2>/dev/null)
        if [ -n ${ip} ]; then
            echo "${subid},${subname},${ipname},${ip}"
        fi
    done <<< "${iplist}}"
done <<< "${sublist}}"

exit
