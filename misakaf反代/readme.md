# 第一步：准备你的服务器环境
## 安装 Nginx
1. Ubuntu/Debian 系统：
```
apt update
apt install nginx
```
CentOS 系统：
```
yum install nginx
```
2. 安装完成后，启动 Nginx 服务：
```
systemctl start nginx
```
3. 将nginx设置为开机启动：
```
systemctl enable nginx
```
# 第二步：获取 SSL 证书
假设你的域名为emby.qq.com，你可以通过以下方式获取证书
## 使用 Let's Encrypt 申请免费证书（推荐）
1. 设置DNS

确保 acaemby.9227371.xyz 的 DNS A 记录指向你的服务器 IP 地址。

2. 安装 certbot 工具：
```
apt install certbot python3-certbot-nginx
```
3. 运行以下命令为你的域名申请证书：
```
certbot --nginx -d emby.qq.com
```
按照提示操作，成功后 certbot 会自动配置 SSL 证书。
你也可以从其他地方获取 SSL 证书，将证书文件（.cer 和 .key）上传到服务器并放置到 /root/cert/ 目录下。

4. 证书自动更新：

如果使用的是 Let’s Encrypt，证书的有效期为 90 天。你可以通过以下命令自动更新证书：
```
certbot renew
```
为确保自动更新，可以将该命令添加到定时任务`crontab -e`中：
```
0 0 * * * /usr/bin/certbot renew --quiet
```

# 第三步：配置 Nginx
1. 新建一个配置文件
```
nano /etc/nginx/sites-available/emby.qq.com.conf
```
2. 粘贴以下内容
```
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
    # 你的证书
    ssl_certificate /root/cert/emby.qq.com.cer;
    ssl_certificate_key /root/emby.qq.com.key;

    client_max_body_size 20M;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    location / {
        # 你需要反代的emby服务器域名
        proxy_pass https://emby.aca.best;
        # 你需要反代的emby推流地址
        proxy_redirect https://stream1.misakaf.org/ https://emby.qq.com/s1/;
        proxy_redirect https://stream2.misakaf.org/ https://emby.qq.com/s2/;
        proxy_redirect https://stream3.misakaf.org/ https://emby.qq.com/s3/;
        proxy_redirect https://stream4.misakaf.org/ https://emby.qq.com/s4/;
        # 你需要反代的emby服务器主页
        proxy_set_header Referer "https://emby.aca.best/web/index.html"; 
        proxy_set_header Upgrade $http_upgrade; 
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $proxy_host; 
        proxy_ssl_server_name on; 
        proxy_http_version 1.1;
    }

    location /s1 {
        rewrite ^/s1(/.*)$ $1 break;
        # 你需要反代的emby推流地址
        proxy_pass https://stream1.misakaf.org/;
        proxy_set_header Referer "https://emby.aca.best/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s2 {
        rewrite ^/s2(/.*)$ $1 break;
        # 你需要反代的emby推流地址
        proxy_pass https://stream2.misakaf.org/;
        proxy_set_header Referer "https://emby.aca.best/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s3 {
        rewrite ^/s3(/.*)$ $1 break;
        # 你需要反代的emby推流地址
        proxy_pass https://stream3.misakaf.org/;
        proxy_set_header Referer "https://emby.aca.best/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }

    location /s4 {
        rewrite ^/s4(/.*)$ $1 break;
        # 你需要反代的emby推流地址
        proxy_pass https://stream4.misakaf.org/;
        proxy_set_header Referer "https://emby.aca.best/web/index.html";
        proxy_set_header Host $proxy_host;
        proxy_ssl_server_name on;
        proxy_buffering off;
    }
}

```

3. 激活配置文件：

软链接激活配置（适用于 Ubuntu/Debian 系统），将配置文件链接到 sites-enabled：
```
ln -s /etc/nginx/sites-available/emby.qq.com.conf /etc/nginx/sites-enabled/
```

4. 检查 Nginx 配置文件是否正确：
```
nginx -t
```
如果配置正确，你会看到类似 syntax is ok 和 test is successful 的提示。

5. 重启 Nginx使新配置生效：
```
systemctl restart nginx

```

# 第四步：故障排查

如果遇到问题，可以查看 Nginx 日志来排查：
访问日志：/var/log/nginx/access.log
错误日志：/var/log/nginx/error.log
