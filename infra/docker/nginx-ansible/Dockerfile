# syntax=docker/dockerfile:1.4
FROM nginx:alpine
RUN echo '<h1>Hello, SWR!</h1>' > /usr/share/nginx/html/index.html

# 配置华为云Alpine源
RUN echo "https://repo.huaweicloud.com/alpine/v3.18/main/" > /etc/apk/repositories && \
    echo "https://repo.huaweicloud.com/alpine/v3.18/community/" >> /etc/apk/repositories

VOLUME ["/allinai/apps/ansible/.ssh"]
RUN chown -R root:root /allinai/apps/ansible/.ssh && \
    chmod 700 /allinai/apps/ansible/.ssh
# 启用APK缓存
RUN --mount=type=cache,id=apk-cache,target=/var/cache/apk \
    apk add --update-cache \
    openssh-server \
    python3 \
    py3-pip \
    sudo \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev && \
    pip3 install --break-system-packages --upgrade pip

# 配置华为云PIP源
RUN --mount=type=cache,id=pip-cache,target=/root/.cache/pip \
    pip3 config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple/ && \
    pip3 config set install.trusted-host repo.huaweicloud.com

# 配置SSH
RUN adduser -D ansibleuser && \
    echo "ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    ssh-keygen -A && \
    echo "ansibleuser:Kuangxin8118!" | chpasswd

# 启用PIP缓存安装Ansible
RUN --mount=type=cache,id=pip-cache,target=/root/.cache/pip \
    pip3 install --break-system-packages \
    ansible-core

# 安装Nginx（复用APK缓存）
RUN --mount=type=cache,id=apk-cache,target=/var/cache/apk \
    apk add nginx && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/nginx/conf.d/

# 创建Ansible所需目录
RUN mkdir -p /etc/ansible && \
    echo "[defaults]" > /etc/ansible/ansible.cfg && \
    echo "interpreter_python = /usr/bin/python3" >> /etc/ansible/ansible.cfg

# 配置Nginx目录权限
RUN chown -R ansibleuser:ansibleuser /etc/nginx/conf.d/ && \
    chmod 755 /var/log/nginx

# 安装服务管理工具
RUN apk add openrc && \
    rc-update add nginx default

# 暴露端口
EXPOSE 22 80

# 启动服务
CMD sh -c "nginx && /usr/sbin/sshd -D"

