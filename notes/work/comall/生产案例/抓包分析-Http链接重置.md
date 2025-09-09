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

----  

# Chatgpt分析
# RestTemplate 调用偶发连接被重置问题案例

## 📝 背景

- 项目中使用 `RestTemplate` 调用 WMS 接口。
    
- 接口请求参数通过 **query string** 拼接，POST 请求 **body 为空**。
    
- 在压测或生产环境中，**大多数调用正常**，但偶尔（约 1~2%）会出现 **连接被重置（Connection reset by peer）**。
    

---

## 🚨 现象

通过 Wireshark 抓包，发现异常调用时的交互顺序如下：

1. **客户端**发送 HTTP POST 请求（body 为空）。
    
2. **客户端立刻发 FIN**，表示“请求体发送完毕，不再发送数据，但仍可接收响应”。
    
3. **服务端返回 RST**，直接重置连接。
    
4. 客户端收到 RST，抛出异常。
    

对应报文序号（示例）：

- `No.560`: HTTP POST
    
- `No.561`: FIN, ACK (客户端主动关闭发送方向)
    
- `No.562`: RST (服务端重置连接)
    
- `No.563`: RST (客户端同步关闭)
    

---

## 🔍 原因分析

### 1. 客户端行为（RestTemplate）

- 默认 `RestTemplate` 使用 `HttpURLConnection`，其连接复用能力较弱。
    
- 当 body 为空时，请求报文非常短，`RestTemplate` 写完请求后会立即关闭输出流，触发 **FIN**。
    
- 这并不代表客户端“不等响应”，只是表示“不再发送数据”。
    

### 2. 服务端行为（WMS）

- 服务端收到 **空 body 的 POST 请求**，可能因参数校验失败 / 请求不符合预期，直接关闭连接。
    
- 某些实现（尤其是网关或代理）不会返回 HTTP 错误码，而是直接 **发送 RST** 强制断开。
    

### 3. 偶发性的原因

- **连接复用问题**：偶尔复用到已被服务端关闭的连接。
    
- **服务端负载问题**：高并发时，部分线程处理异常，直接 reset。
    
- **网络中间件（LB/WAF）**：可能在特定条件下拒绝空 body 的 POST 请求。
    
- 所以问题不是必现，而是 **低概率触发**。
    

---

## 🔧 解决方案

### 方案一：调整请求方式

- 如果接口参数是 **JSON body**：
    
    `HttpHeaders headers = new HttpHeaders(); headers.setContentType(MediaType.APPLICATION_JSON); HttpEntity<String> entity = new HttpEntity<>(jsonQRequest, headers); restTemplate.postForObject(reqUrl, entity, String.class);`
    
- 如果接口参数是 **Form 表单**：
    
    `HttpHeaders headers = new HttpHeaders(); headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED); MultiValueMap<String, String> form = new LinkedMultiValueMap<>(); form.add("cid", cid); form.add("q", q); form.add("sign", sign); HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(form, headers); restTemplate.postForObject(reqUrl, entity, String.class);`
    
- 如果接口确实只需要 **query string**，考虑改成 `GET`，而不是发空 body 的 POST。
    

### 方案二：优化 RestTemplate 底层实现

- 使用 **Apache HttpClient** 替代默认 `HttpURLConnection`，支持连接池与稳定的 keep-alive：
    
    `@Bean public RestTemplate restTemplate() {     PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager();     cm.setMaxTotal(200);     cm.setDefaultMaxPerRoute(50);      CloseableHttpClient httpClient = HttpClients.custom()             .setConnectionManager(cm)             .setKeepAliveStrategy(DefaultConnectionKeepAliveStrategy.INSTANCE)             .build();      HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory(httpClient);     factory.setConnectTimeout(5000);     factory.setReadTimeout(10000);      return new RestTemplate(factory); }`
    

### 方案三：排查服务端

- 确认 WMS API 是否允许空 body POST。
    
- 在服务端同时抓包，确认是否由 API 网关或应用主动 reset。
    
- 检查服务端负载情况（是否线程池拒绝 / backlog 满）。
    

---

## ✅ 总结

- **现象**：RestTemplate 调用偶尔触发 **POST → FIN → RST**，报“连接被重置”。
    
- **根因**：客户端发了 **空 body POST**，RestTemplate 提前发 FIN；服务端或中间件不接受该请求，返回 RST。
    
- **特点**：并非必现，而是低概率触发，通常与连接复用 / 负载 / 网络设备有关。
    
- **解决**：确认接口参数位置，避免空 body POST；改用 `Apache HttpClient` 提升连接稳定性。
    

---

👉 这是一个典型的 **生产环境 TCP 异常案例**，提醒我们在使用 RestTemplate 时要注意：

1. 请求格式要与服务端预期一致。
    
2. 默认 HttpURLConnection 不适合高并发生产场景，建议替换为 Apache HttpClient/OkHttp。

## 📊 抓包时序图

### 1. TCP 层交互（异常情况）

客户端 (RestTemplate)                        服务端 (WMS)
-------------------------------------------------------------
[No.560]  PSH, ACK  ----------------------->  接收 HTTP POST
           (POST 报文发送完毕)

[No.561]  FIN, ACK  ----------------------->  表示客户端已发送完数据
                                             (进入 FIN_WAIT_1)

                                             服务端发现请求非法
                                             或无法处理

[No.562]  <-----------------------  RST      服务端强制重置连接
                                             (进入 CLOSED)

[No.563]  RST  ---------------------------->  客户端同步关闭


👉 特点：客户端 FIN 并不是“不等响应”，只是声明“不再发数据”；但服务端没有返回 HTTP 响应，而是直接 RST。

---

### 2. HTTP 层交互（正常预期 vs 异常实际）

#### 正常预期流程

客户端 → 服务端:  POST /api?cid=...&q=...&sign=...
                   Host: wms.example.com
                   Content-Type: application/json
                   Content-Length: 128

                   {"requestNo":"12345", "timeStamp":"169391...", ...}

服务端 → 客户端:  HTTP/1.1 200 OK
                   Content-Type: application/json
                   Content-Length: 256

                   {"code":0,"msg":"success","data":{...}}


#### 实际异常流程

客户端 → 服务端:  POST /api?cid=...&q=...&sign=...
                   Host: wms.example.com
                   Content-Length: 0
                   (body 为空)

客户端 → 服务端:  [FIN] (表示已发完请求)

服务端 → 客户端:  [RST] (认为请求不合法，直接重置)


👉 核心差异：**正常应该有 body（或明确的 Content-Type），但实际报文 body 为空，触发服务端拒绝。**

---

## ✅ 结论补充

- **TCP 层**：表现为 **POST → FIN → RST**。
    
- **HTTP 层**：表现为 **空 body POST 请求**，导致服务端直接 reset，而不是返回 HTTP 错误码。