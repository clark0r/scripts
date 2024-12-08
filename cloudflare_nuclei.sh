#!/bin/bash

API_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
BASE_URL="https://api.cloudflare.com/client/v4/zones"
OUTPUT="dns"

function fetch_all_dns_records() {
    # Inputs: $1 - API Token, $2 - Zone ID
    local API_TOKEN=${API_TOKEN}
    local ZONE_ID="$1"

    # Cloudflare API URL for fetching DNS records
    local API_URL="${BASE_URL}/${ZONE_ID}/dns_records"
    # Initialize page number
    local PAGE=1

    # Set the number of records per page (max is often set by API, e.g., 100)
    local PER_PAGE=50

    # Loop to handle pagination
    while true; do
        # Perform the API call to get DNS records
        local RESPONSE=$(curl -s -X GET "${API_URL}?page=${PAGE}&per_page=${PER_PAGE}" \
            -H "Authorization: Bearer $API_TOKEN" \
            -H "Content-Type: application/json")

        # Check for success status
        if [ $(echo $RESPONSE | jq '.success') != "true" ]; then
            echo "Failed to fetch DNS records, stopping..."
            echo $RESPONSE
                break
        fi

        # Print results of this page
        echo $RESPONSE | jq '.result[] | select(.type == "A" or .type == "CNAME") | {id, name, type, content}'

        # Check if there are more pages
        local TOTAL_PAGES=$(echo $RESPONSE | jq '.result_info.total_pages')
        if [ "$PAGE" -ge "$TOTAL_PAGES" ]; then
            break
        fi

        # Increment page number for next loop
        ((PAGE++))
    done
}

function fetch_zones() {
        # Inputs: $1 - API Token, $2 - Zone ID
        local API_TOKEN=${API_TOKEN}

        local API_URL="${BASE_URL}"

        local RESPONSE=$(curl -sX GET "$BASE_URL" \
                -H "Authorization: Bearer $API_TOKEN" \
                -H "Content-Type: application/json")

        # Check for success status
        if [ $(echo $RESPONSE | jq '.success') != "true" ]; then
                echo "Failed to fetch Zone records, stopping..."
                break
        fi

        # Print results of this page
        echo ${RESPONSE} | jq -r '.result[].id'
}


if [ -e "$OUTPUT" ]; then
        echo "File '$OUTPUT' exists, exiting."
        exit 1
fi

touch $OUTPUT

zones=$(fetch_zones)
for zone in ${zones}
do
        fetch_all_dns_records ${zone} | jq -r '.name | select(. | tostring | contains("domainkey") or startswith("_") | not)' >> $OUTPUT
done

nuclei -up
nuclei -ut
nuclei -o ${OUTPUT}-nuclei.json -j -s medium,high,critical -stats -l $OUTPUT
