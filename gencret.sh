#!/bin/sh

set -e

ROOT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd)"

# 1. 创建对应的文件目录和文件
sudo mkdir -pv /etc/pki/CA/{certs,crl,newcerts,private}
sudo chown -R $(whoami):$(whoami) /etc/pki/CA
touch /etc/pki/CA/{serial,index.txt}
echo 01 >>/etc/pki/CA/serial
CERT_DIR="${ROOT_DIR}/ssl"
if [[ ! -d "${CERT_DIR}" ]]; then
    mkdir -p ${CERT_DIR}
fi

ROOT_CA_KEY="/etc/pki/CA/private/myRootCA.key"
ROOT_CA_CER="/etc/pki/CA/private/myRootCA.cer"
OPENSSL_CONF="${ROOT_DIR}/openssl.cnf"

read -p "Enter your domain [www.example.com]: " DOMAIN

umask 077
if [[ ! -f ${ROOT_CA_CER} ]]; then
    # 2. 生成CA私钥
    openssl genrsa -out ${ROOT_CA_KEY} 4096

    # 3. 生成CA证书
    openssl req -utf8 -new -x509 -key ${ROOT_CA_KEY} -out ${ROOT_CA_CER} -days 36500 -subj "/C=CN/ST=ZheJiang/L=HangZhou/O=Super Inc./OU=Web Security/CN=myRootCA/emailAddress=huangjiandong@test.com"

fi
if [[ ! -f "${CERT_DIR}/${DOMAIN}.cer" ]]; then
    # 4. 生成服务端私钥
    openssl genrsa -out ${CERT_DIR}/$DOMAIN.key 4096

    # 5. 生成服务端证书请求
    openssl req -utf8 -config ${OPENSSL_CONF} -new -out ${CERT_DIR}/$DOMAIN.req -key ${CERT_DIR}/$DOMAIN.key -subj "/C=CN/ST=ZheJiang/L=HangZhou/O=Super Inc./OU=Web Security/CN=$DOMAIN/emailAddress=huangjiandong@test.com"
    # 6. 生成服务端证书
    # 通过CA机构证书对服务器证书进行签名认证
    openssl x509 -req -extfile ${OPENSSL_CONF} -extensions v3_req -in ${CERT_DIR}/$DOMAIN.req -out ${CERT_DIR}/$DOMAIN.cer -CAkey ${ROOT_CA_KEY} -CA ${ROOT_CA_CER} -sha384 -days 36500 -CAcreateserial -CAserial serial
fi

echo "TODO:"
echo "Copy ${CERT_DIR}/$DOMAIN.key to /etc/nginx/ssl/$DOMAIN.key"
echo "Copy ${CERT_DIR}/$DOMAIN.cer to /etc/nginx/ssl/$DOMAIN.cer"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    server_name $DOMAIN;"
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.key;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.cer;"
echo "    ssl_session_cache shared:SSL:1m;"
echo "    ssl_session_timeout 5m;"
echo "    ssl_ciphers HIGH:!aNULL:!MD5;"
echo "    ssl_prefer_server_ciphers on;"
echo "}"
