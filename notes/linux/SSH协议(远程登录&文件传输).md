> SSH（Secure Shell）协议是一种加密网络协议，用于在不安全网络上安全地远程登录、执行命令、传输文件等。它基于客户端-服务器模型，默认端口为**22**。

### **SSH协议核心特点**

- **加密通信**：防止窃听、篡改和中间人攻击。
    
- **身份验证**：支持密码、密钥对（公钥/私钥）等多种认证方式。
    
- **端口转发**：通过SSH隧道加密其他协议（如FTP、VNC）。
    
- **跨平台**：Linux、macOS原生支持，Windows需第三方工具（如PuTTY、OpenSSH）。

### **常用SSH命令**

#### 1. **远程登录**
``` bash
ssh user@hostname
``` 
- **参数**：
    
    - `-p 2222`：指定端口（默认22）。
        
    - `-i ~/.ssh/id_rsa`：指定私钥文件。
        
    - `-X`：启用X11图形界面转发。

#### **2.密钥对生成**
``` bash 
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
``` 
- **默认路径**：`~/.ssh/id_rsa`（私钥）和 `~/.ssh/id_rsa.pub`（公钥）。
    
- **参数**：
    
    - `-t ed25519`：使用更安全的Ed25519算法。
        

#### 3. **公钥部署（免密码登录）**
``` bash
ssh-copy-id user@hostname
``` 
- 将本地公钥（`id_rsa.pub`）写入远程服务器的`~/.ssh/authorized_keys`。
    

#### 4. **文件传输**

- `scp`（Secure Copy Protocol）命令是基于 SSH 协议的文件传输工具，支持本地与远程主机之间的文件或目录复制
### 上传 
  ```bash
# 例如 scp /Users/tanghao/Desktop/pet/2025-pet-th/PET_2025.jmx root@172.16.107.112:/root/jmeter_data/andy/jmx
  
scp 本地文件绝对路径 服务器用户名@ip地址:服务器绝对路径
  ```
### 下载 
```bash 
# 例如 scp -r root@172.16.107.112:/root/minguo_双十一性能脚本.jmx /Users/tanghao/Desktop/pet/2025-pet-th/

scp -r 服务器用户名@ip地址:服务器文件绝对路径 本地绝对路径
```

| 参数   | 说明                      | 示例                                          |
| ---- | ----------------------- | ------------------------------------------- |
| `-r` | 递归复制整个目录                | `scp -r dir user@host:/path`                |
| `-P` | 指定远程主机的 SSH 端口（**注意大写** | `scp -P 2222 file user@host:/path`          |
| `-C` | 启用压缩，加快传输速度             | `scp -C file user@host:/path`               |
| `-i` | 指定用于 SSH 连接的私钥文件        | `scp -i ~/.ssh/id_rsa file user@host:/path` |
| `-p` | 保留原文件的修改时间、访问权限等        | `scp -p file user@host:/path`               |
| `-q` | 静默模式，不显示传输进度条           | `scp -q file user@host:/path`               |
| `-v` | 详细输出，用于调试连接问题           | `scp -v file user@host:/path`               |
| `-l` | 限制带宽（单位为 Kbit/s）        | `scp -l 500 file