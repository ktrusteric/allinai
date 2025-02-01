#!/bin/bash
# 保存为 download_deps.sh
set -e

# 配置缓存目录
CACHE_DIR="/allinai/apps/pip/pip_cache"
mkdir -p "${CACHE_DIR}"

# 使用Alpine容器下载兼容包
docker run --rm \
  -v "${CACHE_DIR}":/output \
  python:3.9-alpine \
  sh -c "apk add --no-cache gcc musl-dev libffi-dev openssl-dev && \
         pip3 download \
           --only-binary=:all: \
           --platform musllinux_1_1_x86_64 \
           -d /output \
           ansible-core \
           jinja2 cryptography pyyaml" 