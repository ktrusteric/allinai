## 路径规范说明

1. **宿主机路径**（Windows环境）：
   ```
   E:\allinai\infra\ansible
   ```

2. **容器内映射路径**：
   ```
   /ansible/playbooks/infra/ansible
   ```

3. **环境变量覆盖**：
   ```powershell
   # 临时修改基准路径
   $env:ANSIBLE_BASE="/custom/path"
   docker-compose up -d
   ``` 

## 目录结构规范

| 路径                        | 用途说明                     |
|----------------------------|----------------------------|
| /infra/migrations          | 数据库SQL语句文件目录           |
| /scripts                   | 运维脚本目录                | 