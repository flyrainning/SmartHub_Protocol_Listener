# SmartHub_Protocol_Listener
Erlang 编写的fastcgi代理监听程序，运行在Docker中。

### 作用

监听端口，收到数据预处理后，转交后方FastCGI进行处理（如php-fpm)

### 特点

支持TCP、UDP连接

采用 Erlang + Docker 实现高并发+伸缩架构。

单次通讯数据不能大于100 byte，适合作为小数据高并发的应用场景，比如物联网数据采集网关。

带有简单CRC校验，自动丢弃无效数据。


### 数据结构

Erlang网关接收数据包格式：

CRC(32bit)+Length(8bit)+Protocol(8bit)+Data(...n bit)

其中Protocol和Data会作为变量传递到fastcgi进行处理。

### 构建

```
docker build -t smarthub_protocol_listener:1.0 .
```

### 运行

```
docker run -d \
  -p 8018:8018/tcp \
  -p 8018:8018/udp \
  -e FCGI_SERVER=127.0.0.1 \
  -e FCGI_PORT=9000 \
  -e FCGI_FILE=/app/app.php \
  smarthub_protocol_listener:1.0 
```
