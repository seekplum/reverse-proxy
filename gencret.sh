
#!/bin/sh

set -e

# 1. 创建对应的文件目录和文件
sudo mkdir -pv /etc/pki/CA/{certs,crl,newcerts,private}
sudo chown -R $(whoami):$(whoami) /etc/pki/CA
touch /etc/pki/CA/{serial,index.txt}
echo 01 >> /etc/pki/CA/serial
mkdir -p ~/https

read -p "Enter your domain [www.example.com]: " DOMAIN

# 2. 生成CA私钥
umask 077; openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096

# 3. 生成CA证书
SUBJECT="/C=ZG/ST=ZheJiang/L=HangZhou/O=HJD/OU=Test/CN=$DOMAIN/emailAddress=huangjiandong@test.com"
openssl req -new -x509 -subj $SUBJECT -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650

# 4. 生成服务端私钥
openssl genrsa -out ~/https/$DOMAIN.pem 4096

# 5. 生成服务端证书请求
openssl req -new -key ~/https/$DOMAIN.pem -out ~/https/$DOMAIN.csr -days 365 -subj $SUBJECT

# 6. 生成服务端证书
openssl ca -in ~/https/$DOMAIN.csr -out ~/https/$DOMAIN.crt -days 365

echo "TODO:"
echo "Copy ~/https/$DOMAIN.crt to /etc/nginx/ssl/$DOMAIN.crt"
echo "Copy ~/https/$DOMAIN.pem to /etc/nginx/ssl/$DOMAIN.pem"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    server_name $DOMAIN;"
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.crt;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.pem;"
echo "    ssl_session_cache shared:SSL:1m;"
echo "    ssl_session_timeout 5m;"
echo "    ssl_ciphers HIGH:!aNULL:!MD5;"
echo "    ssl_prefer_server_ciphers on;"
echo "}"
