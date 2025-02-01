#!/usr/bin/env bash

CONFIG_FILE="${1:-openrestyconfig.yaml}"

echo "[DEBUG] 实际使用的配置文件: $CONFIG_FILE"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[ERROR] 找不到配置文件: $CONFIG_FILE"
  exit 1
fi

# 读取instances 数组长度
INSTANCES_COUNT=$(yq e '.instances | length' "$CONFIG_FILE" 2>/dev/null)
echo "[DEBUG] 检测到实例数: $INSTANCES_COUNT"

if [ "$INSTANCES_COUNT" -eq 0 ]; then
  echo "[ERROR] 配置文件中没有任何实例."
  exit 1
fi

# 循环打印每个实例的port
for i in $( seq 0 $((INSTANCES_COUNT - 1)) ); do
  port_val=$(yq e ".instances[$i].port" "$CONFIG_FILE" 2>/dev/null)
  
  if [ -z "$port_val" ] || [ "$port_val" == "null" ]; then
    echo "[ERROR] 第$(($i+1))个实例缺 port 字段, 跳过."
    continue
  fi
  
  echo "[OK] 第$(($i+1))个实例 port=$port_val"
done