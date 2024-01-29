#!/bin/bash

cf_apikey=abc123

# get list of zones
curl -s --request GET --url https://api.cloudflare.com/client/v4/zones \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer ${cf_apikey}' | jq '.result[].id' > /tmp/zones

sed -ie 's/"//g' /tmp/zones

# get dns records for zone
for x in $(cat /tmp/zones)
do

        curl -s --request GET \
          --url https://api.cloudflare.com/client/v4/zones/${x}/dns_records/export \
          --header 'Content-Type: application/json' \
          --header 'Authorization: Bearer ${cf_apikey}' >> /tmp/dns
done

# filter to A and CNAME records, remove _domainkey, retain only hostnames
cat /tmp/dns | grep -v SOA | grep -v ";" | grep -v "TXT" | grep -v _domainkey | grep A | cut -f1 | sed 's/.$//' > /tmp/assets

# update nuclei engine and templates, then GOOOOOOO
go/bin/nuclei -up
go/bin/nuclei -ut
go/bin/nuclei -o /tmp/results -cup -l /tmp/assets
