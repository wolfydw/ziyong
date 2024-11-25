# 第一步：准备你的服务器环境

## 安装 Nginx

### Ubuntu/Debian 系统
```bash
apt update
apt install nginx
```

### CentOS 系统
```bash
yum install nginx
```

### 启动 Nginx 服务
```bash
systemctl start nginx
```

### 设置开机启动
```bash
systemctl enable nginx
```

---

# 第二步：获取 SSL 证书

假设你的域名为 `emby.qq.com`，可以通过以下步骤获取证书。

## 使用 Let's Encrypt 申请免费证书（推荐）

### 1. 设置 DNS
确保 `emby.qq.com` 的 DNS A 记录指向你的服务器 IP 地址。

### 2. 安装 certbot 工具
```bash
apt install certbot python3-certbot-nginx
```

### 3. 申请证书
运行以下命令为你的域名申请证书：
```bash
certbot --nginx -d emby.qq.com
```
按照提示操作，成功后 certbot 会自动配置 SSL 证书。

你也可以从其他地方获取 SSL 证书，并将证书文件（`.cer` 和 `.key`）上传到服务器的 `/root/cert/` 目录下。

### 4. 配置证书自动更新
Let’s Encrypt 证书有效期为 90 天，可以通过以下命令更新证书：
```bash
certbot renew
```
为确保自动更新，可以将命令添加到定时任务中：
```bash
crontab -e
```
添加以下内容：
```bash
0 0 * * * /usr/bin/certbot renew --quiet
```

---

# 第三步：配置 Nginx

### 1. 新建配置文件
```bash
nano /etc/nginx/sites-available/emby.qq.com.conf
```

### 2. 粘贴以下内容
```nginx
server {
    listen 80;
    # 你的域名
    server_name emby.qq.com;
    return 301 https://$host$request_uri;
}

map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl http2;
    # 你的域名
    server_name emby.qq.com;
    # 你的证书路径
    ssl_certificate /root/cert/emby.qq.com.cer;
    ssl_certificate_key /root/cert/emby.qq.com.key;

    client_max_body_size 20M;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    location / {
        # 反向代理的 emby 服务器域名
        proxy_pass https://aca.misakaf.org;
        # 反代的 emby 推流地址
        proxy_redirect https://stream1.misakaf.org/ https://emby.qq.com/s1/;
        proxy_redirect https://stream2.misakaf.org/ https://emby.qq.com/s2/;
        proxy_redirect https://stream3.misakaf.org/ https://emby.qq.com/s3/;
        proxy_redirect https://stream4.misakaf.org/ https://emby.qq.com/s4/;
        # 反代 emby 服务器主页
        proxy_set_header Referer "https://aca.misakaf.org/web/index.html"; 
        proxy_set_header Upgrade $http_upgrade; 
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $proxy_host; 
        proxy_ssl_server_name on; 
        proxy_http_version 1.1;
    }

    location /s1 {
        rewrite ^/s1(/.*)$ $1 break;
        proxy_pass https://stream1.misakaf.org/;
        proxy_set_header Referer "https://aca.misakaf.org/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s2 {
        rewrite ^/s2(/.*)$ $1 break;
        proxy_pass https://stream2.misakaf.org/;
        proxy_set_header Referer "https://aca.misakaf.org/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s3 {
        rewrite ^/s3(/.*)$ $1 break;
        proxy_pass https://stream3.misakaf.org/;
        proxy_set_header Referer "https://aca.misakaf.org/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s4 {
        rewrite ^/s4(/.*)$ $1 break;
        proxy_pass https://stream4.misakaf.org/;
        proxy_set_header Referer "https://aca.misakaf.org/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }
}
```

### 3. 激活配置文件
通过软链接激活配置文件：
```bash
ln -s /etc/nginx/sites-available/emby.qq.com.conf /etc/nginx/sites-enabled/
```

### 4. 检查 Nginx 配置
```bash
nginx -t
```
如果配置正确，会显示：
```
syntax is ok
test is successful
```

### 5. 重启 Nginx
```bash
systemctl restart nginx
```

---

# 第四步：故障排查

如果遇到问题，可以查看 Nginx 日志：

- **访问日志**：`/var/log/nginx/access.log`
- **错误日志**：`/var/log/nginx/error.log`
