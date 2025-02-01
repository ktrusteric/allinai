#!/usr/bin/env bash

###############################################################################
# 多次编译安装 OpenResty (仅编译+生成配置, 无 systemd)
# 覆盖已有 nginx.conf, 并在某实例安装出错时继续处理后续实例
#
# 用法:
#   ./install_openresty_multi.sh /path/to/openrestyconfig.yaml
###############################################################################

# 若未指定配置文件, 默认读取当前目录下 openrestyconfig.yaml
CONFIG_FILE="${1:-openrestyconfig.yaml}"  

echo "[INFO] Using config file: $CONFIG_FILE"  
if [ ! -f "$CONFIG_FILE" ]; then  
  echo "[ERROR] No such file: $CONFIG_FILE"  
  exit 1  
fi  

echo "[INFO] Checking instances in $CONFIG_FILE:"  
yq e '.instances' "$CONFIG_FILE"  
echo "============================================"  

INSTANCES_COUNT=$(yq e '.instances | length' "$CONFIG_FILE" 2>/dev/null)  
if [ "$INSTANCES_COUNT" -eq 0 ]; then  
  echo "[ERROR] No instances found."  
  exit 1  
fi  

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[ERROR] 找不到配置文件: $CONFIG_FILE"
  echo "请在脚本后附上配置文件路径, 例如:"
  echo "  $0 /path/to/openrestyconfig.yaml"
  exit 1
fi

# 准备解析 openrestyhome, version
OPENRESTY_HOME=$(yq e '.openrestyhome' "$CONFIG_FILE" 2>/dev/null)
VERSION=$(yq e '.version' "$CONFIG_FILE" 2>/dev/null)

[ -z "$OPENRESTY_HOME" ] || [ "$OPENRESTY_HOME" == "null" ] && OPENRESTY_HOME="/usr/local/openresty"
[ -z "$VERSION" ] || [ "$VERSION" == "null" ] && VERSION="1.21.4.1"

# 解析 global 下 user, group, compile_options
GLOBAL_USER=$(yq e '.global.user' "$CONFIG_FILE" 2>/dev/null)
GLOBAL_GROUP=$(yq e '.global.group' "$CONFIG_FILE" 2>/dev/null)
GLOBAL_COMPILE_OPTS=$(yq e '.global.compile_options[]' "$CONFIG_FILE" 2>/dev/null || true)

[ -z "$GLOBAL_USER" ] || [ "$GLOBAL_USER" == "null" ] && GLOBAL_USER="nginx"
[ -z "$GLOBAL_GROUP" ] || [ "$GLOBAL_GROUP" == "null" ] && GLOBAL_GROUP="nginx"

# 读取 instances
INSTANCES_COUNT=$(yq e '.instances | length' "$CONFIG_FILE" 2>/dev/null)
if [ "$INSTANCES_COUNT" -eq 0 ]; then
  echo "[ERROR] 配置文件中没有任何实例 (instances)."
  exit 1
fi

echo "==================================================================="
echo "[INFO] starting multi-instance build of OpenResty..."
echo "[INFO] openrestyhome = $OPENRESTY_HOME"
echo "[INFO] version       = $VERSION"
echo "[INFO] user/group    = ${GLOBAL_USER}:${GLOBAL_GROUP}"
echo "[INFO] compile opts  =$GLOBAL_COMPILE_OPTS"
echo "==================================================================="

# 保证后续就算出错, 也不影响安装下一个
# 将 'set -e' 改为手动判断上一条命令的退出码, 不要自动退出
set +e

# 逐个实例编译安装
yq e '.instances[]' "$CONFIG_FILE" | while read -r instance; do
  INSTANCE_NAME=$(echo "$instance" | yq e '.name' -)
  INSTANCE_ENV=$(echo "$instance" | yq e '.env' -)
  INSTANCE_MODULE=$(echo "$instance" | yq e '.module' -)
  INSTANCE_PORT=$(echo "$instance" | yq e '.port' -)

  if [ -z "$INSTANCE_PORT" ] || [ "$INSTANCE_PORT" == "null" ]; then
    echo "[ERROR] 发现无效实例配置，跳过"
    continue
  fi

  PREFIX="${OPENRESTY_HOME}/${INSTANCE_NAME}"

  echo
  echo "######################################################################"
  echo "[STEP] 安装第 $(($i+1))/${INSTANCES_COUNT} 个实例: prefix=$PREFIX, port=$INSTANCE_PORT"
  echo "######################################################################"

  # 创建临时编译目录
  WORK_DIR=$(mktemp -d)
  cd "$WORK_DIR" || exit 1

  SRC_URL="https://openresty.org/download/openresty-${VERSION}.tar.gz"
  echo "[INFO] 下载 openresty-${VERSION} 源码 => $SRC_URL"
  wget -q --show-progress -O openresty.tar.gz "$SRC_URL"
  if [ $? -ne 0 ]; then
    echo "[ERROR] 下载源码失败, 跳过此实例 $INSTANCE_PORT."
    cd /
    rm -rf "$WORK_DIR"
    continue
  fi

  tar -xzf openresty.tar.gz
  cd "openresty-${VERSION}" || { echo "[ERROR] 解压后文件夹不存在"; cd /; rm -rf "$WORK_DIR"; continue; }

  # 拼装编译选项
  COMPILE_OPTS_STR=""
  for opt in $GLOBAL_COMPILE_OPTS; do
    COMPILE_OPTS_STR="$COMPILE_OPTS_STR $opt"
  done
  COMPILE_OPTS_STR="$COMPILE_OPTS_STR --prefix=${PREFIX}"

  echo "[INFO] ./configure ${COMPILE_OPTS_STR}"
  ./configure $COMPILE_OPTS_STR
  if [ $? -ne 0 ]; then
    echo "[ERROR] configure失败, 跳过此实例 $INSTANCE_PORT."
    cd /
    rm -rf "$WORK_DIR"
    continue
  fi

  make -j"$(nproc)"
  if [ $? -ne 0 ]; then
    echo "[ERROR] make失败, 跳过此实例 $INSTANCE_PORT."
    cd /
    rm -rf "$WORK_DIR"
    continue
  fi

  sudo make install
  if [ $? -ne 0 ]; then
    echo "[ERROR] make install 失败, 跳过此实例 $INSTANCE_PORT."
    cd /
    rm -rf "$WORK_DIR"
    continue
  fi

  echo "[OK] 已安装 -> $PREFIX"
  echo "[INFO] 检查 $PREFIX/nginx/sbin/nginx"

  # 强制覆盖 nginx.conf
  sudo mkdir -p "$PREFIX/nginx/conf" "$PREFIX/nginx/logs"
  cat <<EOF | sudo tee "$PREFIX/nginx/conf/nginx.conf" >/dev/null
user $GLOBAL_USER $GLOBAL_GROUP;
worker_processes auto;
error_log  logs/error.log;
pid logs/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    access_log    logs/access.log;

    server {
        listen $INSTANCE_PORT;
        server_name localhost;

        location / {
            return 200 "OpenResty at port $INSTANCE_PORT.\n";
        }

        location /lua {
            default_type text/plain;
            content_by_lua_block {
                ngx.say("Hello, OpenResty! port: $INSTANCE_PORT")
            }
        }
    }
}
EOF
  if [ $? -eq 0 ]; then
    echo "[INFO] 已覆盖 $PREFIX/nginx/conf/nginx.conf"
  else
    echo "[ERROR] 写入 nginx.conf 失败, 但不影响后续实例安装."
  fi

  # 修改权限
  sudo chown -R "$GLOBAL_USER:$GLOBAL_GROUP" "$PREFIX"

  # 打印完成
  echo "[DONE] (port=$INSTANCE_PORT) 安装完毕, 并已覆盖 nginx.conf."
  
  # 创建 systemd 服务配置（仅首次安装时创建）
  SERVICE_FILE="/etc/systemd/system/openresty@.service"
  if [ ! -f "$SERVICE_FILE" ]; then
    echo "[INFO] 创建 systemd 服务文件: $SERVICE_FILE"
    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=OpenResty Instance %i
After=network.target

[Service]
Type=forking
PIDFile=${OPENRESTY_HOME}/%i/nginx/logs/nginx.pid
ExecStartPre=${OPENRESTY_HOME}/%i/nginx/sbin/nginx -t -c ${OPENRESTY_HOME}/%i/nginx/conf/nginx.conf
ExecStart=${OPENRESTY_HOME}/%i/nginx/sbin/nginx -c ${OPENRESTY_HOME}/%i/nginx/conf/nginx.conf
ExecReload=${OPENRESTY_HOME}/%i/nginx/sbin/nginx -s reload
ExecStop=${OPENRESTY_HOME}/%i/nginx/sbin/nginx -s quit
User=$GLOBAL_USER
Group=$GLOBAL_GROUP

[Install]
WantedBy=multi-user.target
EOF
    if [ $? -eq 0 ]; then
      echo "[OK] 服务文件已创建，需要执行以下命令生效:"
      echo "sudo systemctl daemon-reload"
    else
      echo "[WARN] 服务文件创建失败，请手动配置"
    fi
  else
    echo "[INFO] 检测到已有服务文件: $SERVICE_FILE (跳过创建)"
  fi

  cd /
  rm -rf "$WORK_DIR"
done

echo
echo "[ALL DONE] 全部实例处理完毕。"
echo "启动单个实例命令:"
echo "  sudo systemctl start openresty@${INSTANCE_PORT}"
echo "设置开机自启:"
echo "  sudo systemctl enable openresty@${INSTANCE_PORT}"