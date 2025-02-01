#!/bin/bash
# 保存为 /allinai/docker/nginx-ansible/update_all_cache.sh
set -e

# 配置目录
BASE_DIR="/allinai/docker/nginx-ansible"
APK_CACHE="${BASE_DIR}/apk_cache"
PIP_CACHE="${BASE_DIR}/pip_cache"

# 创建缓存目录
mkdir -p "${APK_CACHE}" "${PIP_CACHE}"
chmod 755 "${APK_CACHE}" "${PIP_CACHE}"

# 更新APK缓存
echo "Updating APK cache..."
docker run --rm \
  -v "${APK_CACHE}":/var/cache/apk \
  alpine:3.18 \
  sh -c "apk update && \
         apk add --no-cache \
           openssh-server \
           python3 \
           py3-pip \
           sudo \
           gcc \
           musl-dev \
           libffi-dev \
           openssl-dev"

# 更新PIP缓存
echo "Updating PIP cache..."
docker run --rm \
  -v "${PIP_CACHE}":/cache \
  python:3.9-alpine \
  sh -c "apk add --no-cache gcc musl-dev libffi-dev openssl-dev && \
         pip3 download \
           --only-binary=:all: \
           --platform musllinux_1_1_x86_64 \
           --python-version 39 \
           -d /cache \
           ansible-core \
           jinja2 cryptography pyyaml"

# 设置文件权限
find "${APK_CACHE}" -type f -exec chmod 644 {} \;
find "${PIP_CACHE}" -type f -exec chmod 644 {} \;

echo "Cache update completed!" 