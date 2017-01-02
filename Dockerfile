
FROM erlang:19.1.6
MAINTAINER Flyrainning "http://www.fengpiao.net"


ENV FCGI_SERVER 127.0.0.1
ENV FCGI_PORT 9000
ENV FCGI_FILE /app/app.php
ENV PORT 8018

ADD app /app
WORKDIR /app

RUN chmod a+x /app/run.sh

EXPOSE 8018 8018/udp
ENTRYPOINT ["/app/run.sh"]

