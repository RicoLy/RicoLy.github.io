---
layout: post
title: mysql一键生成APIs应用
category: Golang
tags: Golang
description: mysql数据库一行命令生成GIN+GORM RESTful APIs Golang应用
---



## [一行命令根据mysql数据库生产RESTful APIs APP](https://github.com/dejavuzhou/ginbo)
##### Ginbo,GinBro,Gimbo,GimBro,**Jimbo**,GinOrm or GinGorm
## Feature
- 自动生成完善的swagger(postman)文档
- 可以server SPA应用(比如vuejs全家桶)
- 快速使用golang+gin+gorm改造依赖mysql项目
    
## ginbo工具安装
您可以通过如下的方式安装 bee 工具：
```shell
go get github.com/dejavuzhou/ginbo
```
安装完之后，`ginbo` 可执行文件默认存放在 `$GOPATH/bin` 里面，所以您需要把 `$GOPATH/bin` 添加到您的环境变量中，才可以进行下一步。
如何添加环境变量，请自行搜索
如果你本机设置了`GOBIN`,那么上面的命令就会安装到 `GOBIN`下，请添加`GOBIN`到你的环境变量中

## 使用
`ginbo gen -u root -p PASSWORD -a "127.0.0.1:3306" -d dbname -o "github.com/mojocn/apiapp"`
- cd 到生成的项目
- go build  和run
- 访问[`http://127.0.0.1:5555/swagger`](http://127.0.0.1:5555/swagger)

### 生成新project目录树 [ginbo-son DEMO代码](https://github.com/dejavuzhou/ginbo-son)
```shell
C:\Users\zhouqing1\go\src\github.com\mojocn\apiapp>tree /f /a
Folder PATH listing
Volume serial number is 8452-D575
C:.
|   2018-11-15-app.log
|   config.toml
|   main.go
|   readme.md
|
+---config
|       viper.go
|
+---handlers
|       gin.go
|       handler_wp_litespeed_img_optm.go
|       handler_wp_litespeed_optimizer.go
|       handler_wp_posts.go
|       handler_wp_users.go
|       handler_wp_yoast_seo_links.go
|
+---models
|       db.go
|       model_wp_litespeed_img_optm.go
|       model_wp_litespeed_optimizer.go
|       model_wp_posts.go
|       model_wp_users.go
|       model_wp_yoast_seo_links.go
|
+---static
|   |   .gitignore
|   |   index.html
|   |   readme.md
|   |
|   \---index_files
|           jquery.js.download
|           style.css
|           syntax.css
|
\---swagger
        .gitignore
        doc.yml
        favicon-16x16.png
        favicon-32x32.png
        index.html
        oauth2-redirect.html
        readme.md
        swagger-ui-bundle.js
        swagger-ui-standalone-preset.js
        swagger-ui.css
        swagger-ui.js
```
### 命令参数说明
```shell
ginbo gen -h
generate a RESTful APIs app with gin and gorm for gophers. For example:
        ginbo gen -u eric -p password -a "127.0.0.1:3306" -d "mydb"

Usage:
  create gen [flags]

Flags:
  -a, --address string    mysql host:port (default "dev.mojotv.com:3306")
  -l, --appAddr string    app listen Address eg:mojotv.cn, use domain will support gin-TLS (default "127.0.0.1:5555")
  -c, --charset string    database charset (default "utf8")
  -d, --database string   database name (default "dbname")
  -h, --help              help for gen
  -o, --out string        golang project package name of your output project. eg: github.com/awesome/my_project, the project will be created at $GOPATH/src/github.com/awesome/my_project (default "github.
com/dejavuzhou/gin-project")
  -p, --password string   database password (default "Password")
  -u, --user string       database user name (default "root")
```
## 环境
- 我的开发环境
    - Windows 10 专业版 64位
    - go version go1.11.1 windows/amd64
    - mysql 数据库 <= 5.7

## 依赖
```shell
go get -u github.com/gin-contrib/cors
go get -u github.com/gin-contrib/static
go get -u github.com/gin-gonic/autotls
go get -u github.com/gin-gonic/gin
go get -u github.com/sirupsen/logrus
go get -u github.com/spf13/viper
go get -u github.com/spf13/cobra
go get -u github.com/go-redis/redis
go get -u github.com/go-sql-driver/mysql
go get -u github.com/jinzhu/gorm
```
## 开发计划

- [ ] 支持PostgreSQL数据库
- [ ] 支持一键生产jwt密码验证
- [ ] 支持MongoDB数据库
- [ ] 更具数据映射关联模型
- [ ] 分页总数做redis缓存
- [ ] 支持生成gRPC服务
- [ ] 更详细的gorm tag信息
- [ ] json不现实password等隐私字段
- [ ] swaggerDoc参数说明继续优化
- [ ] 生成友好的.gitignore
- [ ] 完善go doc

## 注意
- mysql表中没有id/ID/Id/iD字段将不会生成路由和模型
- json字段 在update/create的时候 必须使可以序列号的json字符串,否则mysql会报错

## 致谢
- [gin-gonic/gin框架](https://github.com/gin-gonic/gin)
- [GORM数据库ORM](http://gorm.io/)
- [viper配置文件读取](https://github.com/spf13/viper)
- [cobra命令行工具](https://github.com/spf13/cobra#getting-started)

## 请各位大神不要吝惜提`issue`同时附上数据库表结构文件