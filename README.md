# Http 反向代理到 Https

## 背景

1. 我有一台内网开发环境机器 dev，没有公网 IP
2. dev 可以访问 https://www.baidu.com，访问必须走 https 协议
3. 内网中其它机器 无法直接访问 https://www.baidu.com
4. 反向代理服务需要部署在 dev 机器上，以 Docker 容器方式启动，对外提供服务能力的端口设置为 8083
5. 使用场景是开发环境，可以忽略 SSL 证书验证，可以使用系统内置的 CA 证书验证服务器证书的合法性

## 下载 CA 文件

```bash
curl https://curl.se/ca/cacert.pem -o certs/cacert.pem
```

## 生成证书

```bash
echo "localhost" | bash ./gencret.sh
```

## 部署

```bash
bash ./deploy.sh down

bash ./deploy.sh up
```

## 访问示例

```bash
curl http://www.baidu.com --proxy http://dev:8083

curl -fsSLk http://localhost:8086 -H "Host: www.test.com"
curl -fsSLk http://www.test.com/api/get --proxy http://127.0.0.1:8086

curl -fsSLk https://localhost/api/get
curl -fsSLk https://localhost/xxxx -H "Host: www.test.com"
curl -fsSLk https://localhost/api/get -H "Host: www.test.com"
```
