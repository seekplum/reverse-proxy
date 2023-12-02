#!/usr/bin/env bash

ETVAL=0

set -e

ROOT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

function dco() {
    docker-compose -f "${ROOT_DIR}/docker-compose.yml" $*
}

print_help() {
    echo "Usage: bash $0 {-h|dco|up|down|up-force}"
    echo "e.g: $0 dco config"
}

# 命令行参数小于 1 时打印提示信息后退出
if [ $# -lt 1 ] ; then
    print_help
    exit 1;
fi

case "$1" in
  dco)
        dco ${@:2}
        ;;
  up)
        dco up -d
        ;;
  down)
        dco down --remove-orphans -v
        ;;
  up-force)
        dco up -d --force-recreate
        ;;
  -h|--help)
        print_help
        ETVAL=1
        ;;
  *)  # 匹配都失败执行
        print_help
        ETVAL=1
esac

exit ${ETVAL}
