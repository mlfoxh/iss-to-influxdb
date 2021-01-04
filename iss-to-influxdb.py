import os
import requests
import json
import time
from math import *

def getDist(lat1, lon1, lat2, lon2):
    # convert coordinates to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])

    # get distance between coordinates
    distLat = lat1 - lat2
    distLon = lon1 - lon2
    
    # haversine formula
    a = sin(distLat/2)**2 + cos(lat1) * cos(lat2) * sin(distLon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    distance = c * 6371

    return distance

def getBearing(lat1, lon1, lat2, lon2):
    # convert coordinates to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])

    distLon = lon2 - lon1
    x = sin(distLon) * cos(lat2)
    y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(distLon)

    bearing = degrees(atan2(x, y))

    # convert to compass bearing
    compass = (bearing + 360) % 360
    
    return compass

def main():
    # get configured ground location
    userLat = float(os.environ['LATITUDE'])
    userLon = float(os.environ['LONGITUDE'])

    # get configured influxdb information
    influxAddress = os.environ['INFLUXDB_ADDRESS']
    influxDatabase = os.environ['INFLUXDB_DATABASE']
    influxUser = os.environ['INFLUXDB_USER']
    influxPassword = os.environ['INFLUXDB_PASSWORD']

    # configure post usl
    url = influxAddress + "/write?db=" + influxDatabase + "&u=" + influxUser + "&p=" + influxPassword

    # get configured interval
    interval = int(os.environ['INTERVAL'])

    # loop forever
    while True:
        # get iss position json data
        try:
            data = requests.get('http://api.open-notify.org/iss-now.json').json()

            # pull lat/lon and timestamp from data
            issLat = float(data['iss_position']['latitude'])
            issLon = float(data['iss_position']['longitude'])
            timestamp = int(data['timestamp']) * 1000000000

            # get distance
            issDist = getDist(userLat, userLon, issLat, issLon)

            # get bearing
            issBearing = getBearing(userLat, userLon, issLat, issLon)

            # print data for log
            print("time: ", timestamp)
            print("lat:", issLat)
            print("lon: ", issLon)
            print("distance: ", issDist)
            print("bearing: ", issBearing)

            # format data
            influxData = "position latitude=" + str(issLat) + ",longitude=" + str(issLon) + ",distance=" + str(issDist) + ",bearing=" + str(issBearing) + " " + str(timestamp)

            # send data
            requests.post(url, data = influxData)

        finally:
            # wait before looping
            time.sleep(interval)

main()
