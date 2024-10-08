---
layout: post
title: Goland远程开发调试
category: Golang
tags: Golang
description: Goland远程开发调试
---


1\. 远程调试Debug优点
---------------

1.  极大的加快开发速度,减少给在代码中使用大量log来定位错误.
2.  最大程度的使用linux远程服务器环境, 极大的简化本地部署模拟服务器环境
3.  可以绕过数据库内网的限制
4.  不用依赖日志来定位错误(开发效率太低)
5.  完美的解决一些不支持windows开发的依赖

2\. Go远程调试Debug
---------------

### 2.1 linux　安装Golang环境

    #https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
    VERSION='1.13.4';#设置go语言版本 指定您的版本
    OS=linux # 可选值 linux darwin
    ARCH=amd64 #可选值 但是必须与您的操作系统匹配 amd64, 386, arm (树莓派raspberryPi3), arm64, s390x, ppc64le
    GZFILE="go$VERSION.$OS-$ARCH.tar.gz" # 下载的安装名称包含arch
    wget "https://dl.google.com/go/${GZFILE}";
    rm -rf /usr/local/go; # 删除旧的go安装文件
    tar -C /usr/local -xzf $GZFILE; #解压文件到 /usr/local/go目录中


在您是linux的 vim 环境变量文件(~/.bashrc /etc/profile)最后添加一下3行代码:

    export GOPATH=/opt/go
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN


重新加载环境变量文件: `mkdir -p $GOBIN;` 创建目录 `source /etc/profile` or `source ~/.bashrc`

### 2.2 linux服务器安装Delve

文档 [linux 安装Delve](https://github.com/go-delve/delve/blob/master/Documentation/installation/linux/install.md)

    git clone https://github.com/go-delve/delve.git $GOPATH/src/github.com/go-delve/delve
    cd $GOPATH/src/github.com/go-delve/delve
    make install
    # dlv 在您的$GOBI目录
    ls $GOBIN
    dlv # 不报错证明安装好了


### 2.2 Goland SFTP 自动同步代码(SMBA也可以)

如果找不到SFTP,请安装SFTP Plugin, Goland 添加SFTP: Goland菜单: Tools -> Deployment -> Configuration 加号 ![Goland 添加SFTP](/assets/image/remote_debug01.png)

Goland SFTP 本地代码目录映射

![本地代码目录映射](/assets/image/remote_debug02.png)

勾选自动上传Goland菜单: Tools -> Deployment -> Auto Upload(Always)

### 2.3 服务器开启Delve 服务

    cd ~/go_project; # golang 代码目录
    go build -o app.exe; # 编译golang代码
    dlv --listen=:2345 --headless=true --api-version=2 exec ~/go_project/app.exe api; # 开启delve服务  其中 api 是golang程序的参数


建议把上面的命令自定为linux 当前用户的profile文件的alias 参考我的 `~/.bashrc` 文件, 我定义了一个 debugm 命令来调试go代码.

    # .bashrc
    # Source global definitions
    if [ -f /etc/bashrc ]; then
            . /etc/bashrc
    fi
    export GOBIN=/gobin;
    export PATH=$PATH:/usr/local/go/bin:$GOBIN;
    
    export GOPROXY=https://goproxy.io
    export GO111MODULE=on
    alias debugm="cd ~/go_project; go build -o app.exe; dlv --listen=:2345 --headless=true --api-version=2 exec ~/go_project/app.exe api"


### 2.4 Goland Debug 配置

填写linux 服务的ip 和 delve的端口,自己设置防火墙.

![](/assets/image/remote_debug03.png)

### 2.5 Goland打断点

每次代码更新的适合需要在linux中 ctrl+c, 在执行debugm(自定义命令) linux 服务器中:

    [eric@mojotv.cn ~]$ cat ~/.bashrc #查看当前用户的profile 配置
    [eric@mojotv.cn ~]$ debugm # 执行自定义的命令
    API server listening at: [::]:2345



在Goland中点击debug按钮

![](/assets/image/remote_debug04.png)

    [mojotv.cn@p28537v yzt]$ debugm
    API server listening at: [::]:2345
    # Golang 点击虫子按钮之后打印出来的
    2019/11/27 19:09:29 访问 http://127.0.0.1:9527/swagger-doc for RESTful APIs Swagger 文档
    [GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
     - using env:	export GIN_MODE=release
     - using code:	gin.SetMode(gin.ReleaseMode)
    
    [GIN-debug] GET    /swagger-doc/*filepath    --> github.com/gin-gonic/gin.(*RouterGroup).createStaticHandler.func1 (3 handlers)
    [GIN-debug] HEAD   /swagger-doc/*filepath    --> github.com/gin-gonic/gin.(*RouterGroup).createStaticHandler.func1 (3 handlers)
    INFO[0000] start asset sync runner...                   
    [GIN-debug] GET    /screen-shot/assets/:id   --> marvel/handler.AssetScreenShot (4 handlers)
    [GIN-debug] GET    /api/v1/admin-division    --> marvel/handler.AdminDivision (4 handlers)
    ...
    [GIN-debug] Listening and serving HTTP on 0.0.0.0:9527



Goland断点效果 ![](/assets/image/remote_debug05.png)
