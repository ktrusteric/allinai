#!/usr/bin/env python3
"""
功能：根据实例配置动态生成主机清单
逻辑：
  1. 读取组变量中的实例配置
  2. 根据端口号生成模拟IP（示例：端口8080 -> 192.168.1.80）
  3. 生成标准Ansible主机清单格式
"""
import yaml

def generate_hosts(config_path):
    # 读取配置文件
    with open(config_path) as f:
        config = yaml.safe_load(f)
    
    # 生成主机条目
    hosts = []
    ip_base = "192.168.11"  # 可配置化
    for instance in config['instances']:
        # 示例IP生成逻辑（实际应根据环境调整）
        host_entry = f"{instance['name']} ansible_host={ip_base}.{instance['port'][-2:]}"
        hosts.append(host_entry)
    
    # 写入主机清单文件
    with open('inventory/production/hosts', 'w') as f:
        f.write("[openresty_servers]\n")
        f.write("\n".join(hosts))

if __name__ == "__main__":
    generate_hosts("inventory/production/group_vars/openresty.yaml") 