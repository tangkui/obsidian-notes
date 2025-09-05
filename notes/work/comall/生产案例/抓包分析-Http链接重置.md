## 问题
A系统向B系统发起http请求，A系统抛出异常：

```
org.springframework.web.client.ResourceAccessException: I/O error on POST request for "http://47.107.111.21/wms/wy/syn": 47.107.111.21:80 failed to respond; nested exception is org.apache.http.NoHttpResponseException: 47.107.111.21:80 failed to respond
```


## 问题分析
查阅相关资料，apache网站的解释：
> In some circumstances,usually when under heavy load, the web server may be able to receive requests but unable toprocess them. A lack of sufficient resources like worker threads is a good example. This may cause the server to drop the connection tothe client without giving any response. HttpClient throws NoHttpResponseException when it encounters such a condition. In most cases it is safe to retry a method that failed with NoHttpResponseException.

> 意思就是当服务器端由于负载过大等情况发生时，可能会导致在收到请求后无法处理(比如没有足够的线程资源)，会直接丢弃链接而不进行处理。此时客户端就回报错：NoHttpResponseException。 建议出现这种情况时，可以选择重试。

根据官方说明，协调B系统确认服务器远未达到过载程度。

## 排查过程

1. 确认系统间网络链路是否正常，主要通过ping和telnet命令检查；

 B系统禁ping，无法确认网络情况； 

 通过telnet确认网络正常；

> 总结：系统间网络正常

2. 复现问题，抓包分析请求内容。

在A服务器安装tcpdum抓包工具

> ``` yum install tcpdump ```

安装后执行抓包命令：

> ``` tcpdump -i any -s 0 -w netfile.cp ```

发起请求，复现问题，此后，tcpdump已抓取该服务器所有网络交互数据包，下载netfile.cp文件到本地，导入至wireshark抓包工具，进行分析。

找到目标请求：
![[Pasted image 20250905144202.png]]

跟踪TCP流，查看交互过程：
![[Pasted image 20250905144236.png]]

通过最后一张图片红框内信息可以发现，A系统发起请求后，交互未完成，B系统主动向A系统发送了RST请求，重置了连接。

可以推断B系统存在HTTP长连接，且本次请求在刚好失效时间内，到达B系统设定的失效时间，则B系统会自动断开连接。

http1.1，默认长连接；

> 总结解决方案：
1、B系统关闭重置长连接配置；
2、A系统设置请求头，关闭长连接，