#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

INTERCONNECT_ATTACHMENT=$1
REGION=$2
PROJECT_ID=$3
OUTPUT_FILE=$4
GCLOUD_BIN=$5
JQ_BIN=$6

max_iterations=20
wait_seconds=6

cloud_router_ip=""
customer_router_ip=""
iterations=0
while true
do
	((++iterations))
	sleep $wait_seconds

	interconnect=$($GCLOUD_BIN compute interconnects attachments describe $INTERCONNECT_ATTACHMENT --region $REGION --project=$PROJECT_ID --format=json)
	cloud_router_ip=$(echo $interconnect | $JQ_BIN -r '.cloudRouterIpAddress')
	customer_router_ip=$(echo $interconnect | $JQ_BIN -r '.customerRouterIpAddress')

	if [ ! -z "$cloud_router_ip" ] && [ ! -z "$customer_router_ip" ]; then
		break
	fi

	if [ "$iterations" -ge "$max_iterations" ]; then
		exit 1
	fi
done

if [ -z "$cloud_router_ip" ] && [ -z "$customer_router_ip" ]; then
	break
fi

[ -z "$cloud_router_ip" ] && echo "GCP - Cloud router is null"
[ -z "$customer_router_ip" ] && echo "GCP - Customer router is null"

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
$JQ_BIN -n --arg cloud_router_ip "$cloud_router_ip" --arg customer_router_ip "$customer_router_ip" '{"cloud_router_ip":$cloud_router_ip,"customer_router_ip":$customer_router_ip}' > $OUTPUT_FILE