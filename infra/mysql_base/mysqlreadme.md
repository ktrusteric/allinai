#for MAC install docker
brew install docker
brew install docker-compose

#build image
cd /Users/eric/allinai/infra/mysql_base
  docker build -t ubuntu/mysql:latest .
 
  docker run -d \
    --name mysql \
    -v /Users/eric/allinai/infra/mysql_base/data:/var/lib/mysql \
    -v /Users/eric/allinai/infra/mysql_base/log:/var/log/mysql \
    -v /Users/eric/allinai/infra/mysql_base/initsql:/initsql \
    -v /Users/eric/allinai/infra/mysql_base/my.conf:/etc/mysql/conf.d/my.conf \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=SecurePass123! \
    ubuntu/mysql:latest

#create database
CREATE DATABASE opcli CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;    