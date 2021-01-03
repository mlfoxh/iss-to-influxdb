FROM python:3-alpine

RUN pip3 install requests

COPY iss-to-influxdb.py /root/iss-to-influxdb.py

ENV LATITUDE=0.0
ENV LONGITUDE=0.0
ENV INFLUXDB_ADDRESS=http://influxdb.domain.tld:8086
ENV INFLUXDB_DATABASE=database
ENV INFLUXDB_USER=user
ENV INFLUXDB_PASSWORD=password
ENV INTERVAL=15

WORKDIR /root/

ENTRYPOINT [ "python3" ]
CMD [ "iss-to-influxdb.py" ]
