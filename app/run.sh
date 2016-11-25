#!/bin/sh
cd /app

for file in ./*.erl
do
erlc $file
done

echo "listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"


erl -pa "/app" -noshell -detached -eval "tcp_server:listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"
erl -pa "/app" -noshell -eval "udp_server:listen(\"$FCGI_SERVER\",$FCGI_PORT,\"$FCGI_FILE\",$PORT)"


