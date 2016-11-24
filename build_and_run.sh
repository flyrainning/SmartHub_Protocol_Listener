#!/bin/sh
docker build -t flyrainning/smarthub_protocol_listener:1.0 .
docker run -d \
  -p 8018:8018/tcp \
  -p 8018:8018/udp \
  -e FCGI_SERVER=127.0.0.1 \
  -e FCGI_PORT=9000 \
  -e FCGI_FILE=/app/app.php \
  flyrainning/smarthub_protocol_listener:1.0 

