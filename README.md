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

Erlang网关接收数据包，默认支持2种格式：

格式1，带CRC校验的数据包，可用于UDP数据包并且数据包未开启校验的情况。

CRC(32bit)+Length(8bit)+Protocol(8bit)+Data(...n bit)

其中Protocol和Data会作为变量传递到fastcgi进行处理。

格式2，用于一般的TCP或者UDP通讯，无校验

shp:(固定32bit头)+Protocol(8bit)+Data(...n bit)

网关解析后会将转Protocol和Data转交后方FastCGI进行处理

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


### 制定解析规则

可以通过docker 的-v参数，将自己编写的预处理代码(.erl文件)挂载到/app/check.erl，实现制定

erl文件必须实现getdata函数，接收Data，返回{ok,{binary_to_list(Protocol),binary_to_list(ResData)}};

可参考app/check.erl
