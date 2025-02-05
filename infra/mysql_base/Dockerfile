# 使用 ubuntu/mysql 基础镜像（请根据实际情况选择合适的标签）
FROM ubuntu/mysql:latest

# 创建 MySQL 数据和日志所需的目录
RUN mkdir -p /var/lib/mysql /var/log/mysql /initsql

# 将默认配置文件复制进镜像作为示例配置文件
# 注意：如果你希望使用主机自定义的配置文件，可在运行容器时绑定挂载 /Users/eric/allinai/infra/mysql_base/my.conf 到此路径
COPY my.conf /etc/mysql/conf.d/my.conf

# 声明数据和日志目录为 volume，以便数据持久化
VOLUME ["/var/lib/mysql", "/var/log/mysql", "/initsql"]

# 暴露默认 MySQL 端口
EXPOSE 3306

# 启动 MySQL 服务（依据你所使用的镜像中启动方式进行调整）
CMD ["mysqld_safe"] 