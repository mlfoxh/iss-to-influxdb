#!/bin/bash
# iss-to-influxdb.sh
# mlfh
# 2020-10-20
# fetches current iss position data from api.open-notify.org, parses, and sends to InfluxDB

# Check to see if ENV variables are set, and source config file if not
if [ -z $INFLUXDB_ADDRESS ]
then
	. config
	echo "Sourcing variables from config file..."
else
	echo "Sourcing ENV variables..."
fi

# Loop fetch/parse/send/wait forever
while true
do
	# Fetch raw data from api.oprn-notify.org
	echo "Fetching data from api.open-notify.org..."
	ISS_POSITION=$(curl --silent http://api.open-notify.org/iss-now.json)
	echo $ISS_POSITION

	# Parse data for values, strip quotes from lat/long json
	LAT=$(echo $ISS_POSITION | jq '.iss_position.latitude' | sed 's/"//g')
	echo "Latitude: $LAT"
	LONG=$(echo $ISS_POSITION | jq '.iss_position.longitude' | sed 's/"//g')
	echo "Longitude: $LONG"
	TIME=$(echo $ISS_POSITION | jq '.timestamp')
	echo "Timestamp: $TIME"
	TIME_NANO=$(($TIME * 1000000000))

	# Send values to InfluxDB
	echo "Sending values to InfluxDB..."
	curl -v --output /dev/null -i -XPOST "$INFLUXDB_ADDRESS/write?db=$INFLUXDB_DATABASE&u=$INFLUXDB_USER&p=$INFLUXDB_PASSWORD" --data-binary \
		"position latitude=$LAT,longitude=$LONG $TIME_NANO"

	# Repeat after interval (seconds)
	echo "Sleeping for $INTERVAL seconds..."
	sleep $INTERVAL
done
