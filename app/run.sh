#!/bin/sh
cd /app

echo "listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"

erlc tcp_server.erl
erlc udp_server.erl

erl -pa "/app" -noshell -detached -eval "tcp_server:listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"
erl -pa "/app" -noshell -eval "udp_server:listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"
