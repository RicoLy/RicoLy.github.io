---
layout: post
title: Vagrant常用操作命令
category: Tool
tags: vagrant
keywords: vagrant
description: Vagrant常用操作命令
---

添加 box
------

### 命令

    $ vagrant box add ADDRESS


向`Vagrant`添加一个具有给定地址的 `box`。地址可以是以下三种情况之一：

*   可用的 `Vagrant` 公共镜像的缩写名称 ，例如`detectionlab/win10`。

    $ vagrant box add  detectionlab/win10


*   本地目录中 `box` 文件路径或`HTTP URL` 。对于`HTTP`，支持基本身份验证，并且`http_proxy`遵守环境变量。还支持`HTTPS`。

    $ vagrant box add win10 D:\vm\virtualbox.box
    $ vagrant box add win10 https://vagrantcloud.com/detectionlab/boxes/win10/versions/1.8/providers/virtualbox.box


*   `URL`直接是一个 `box` 文件。在这种情况下，您必须指定一个`--name`标志。

    $ vagrant box add https://vagrantcloud.com/detectionlab/boxes/win10/versions/1.8/providers/virtualbox.box --name win10


### 选项

*   `--box-version VALUE` -您要添加的`box`的版本。默认情况下，将添加最新版本。此值可以是确切的版本号，例如`"1.2.3"`，也可以是一组版本约束，例如`">=1.0,<2.0"`。  
    `$ vagrant box add detectionlab/win10 --box-version "1.6"`  
    `$ vagrant box add detectionlab/win10 --box-version ">=1.6,<1.8"`

*   `--cacert CERTFILE` -用于验证对等的`CA`的证书。如果远端不使用标准的根`CA`，应使用此选项。

*   `--capath CERTDIR` -用于验证对等的`CA`的证书目录。如果远端不使用标准的根`CA`，则应使用此选项。

*   `--cert CERTFILE` -如有必要，在下载`box`时使用的客户端证书。

*   `--clean` -如果提供，`Vagrant`将从先前下载的相同`URL`中删除所有旧的临时文件。当`URL`对应的内容已经改变时，不希望`Vagrant`从上一点继续下载时，可以使用。

*   `--force` -如果存在，将下载该`box`并覆盖已存在的同名的`box`。

*   `--insecure` -如果存在，当`URL`是`HTTPS URL`时不验证`SSL`证书。

*   `--provider PROVIDER` -如果提供，`Vagrant`将验证您要添加的`box`是否是给定的提供者。默认情况下，`Vagrant`自动检测适合的提供者并使用。


### box 文件的直接选项

仅当您直接添加`box`文件时（不使用目录时），以下选项才适用。

*   `--checksum VALUE` -已下载`box`的校验和。如果指定，`Vagrant`会将此校验和与实际下载的校验和进行比较，如果校验和不匹配，则会出错。强烈建议使用此功能，因为文件夹文件太大。如果已指定，则`--checksum-type`还必须指定。如果要从目录下载，则校验和包含在目录条目中。

*   `--checksum-type TYPE` \- `--checksum`如果指定了校验和的类型。当前支持的值为`md5`，`sha1`，`sha256`，`sha384`和`sha512`。

*   `--name VALUE` -`box`的逻辑名称。这是您要`config.vm.box`在`Vagrantfile`中输入的值。从目录中添加`box`时，名称包含在目录条目中，无需指定。


`版本化的box或HashiCorp的Vagrant Cloud中的box的校验和：对于HashiCorp的Vagrant Cloud中的box，校验和嵌入在box的元数据中。元数据本身通过TLS提供服务，并且其格式经过验证。`

box 列表
------

### 命令

    $ vagrant box list


列出了`Vagrant`中安装的所有`box`。

移除 box
------

    vagrant box remove NAME


从`Vagrant`中删除一个与给定名称匹配的`box`。

如果一个`box`具有多个提供程序，则必须使用该`--provider`标志指定确切的提供者。如果一个`box`具有多个版本，则可以选择带有`--box-version`标志的要删除的版本，或带有标志的所有版本`--all`。

### 选项

*   `--box-version VALUE` -版本限制的版本`box`要删除。

*   `--all` -删除盒子的所有可用版本。

*   `--force` -即使活动的`Vagrant`环境正在使用它，也要强制删除它。

*   `--provider VALUE` -要删除的提供者专有的`box`，并使用给定名称。仅当一个`box`由多个提供者支持时才需要。如果只有一个提供者，`Vagrant`将默认删除它。


打包
--

    vagrant box repackage NAME PROVIDER VERSION


重新打包给定的`box`并将其放在当前目录中，以便您可以重新分发它。可以使用`vagrant box list`查询`box`的名称、提供者和版本。

当您添加一个`box`时，`Vagrant`将其分析并内部存储，原始`*.box`文件未保留。此命令能够从已安装的`Vagrant` `box`中创建一个`*.box`文件。

更新 box
------

    vagrant box update


如果有可用更新，此命令将更新当前`Vagrant`环境的`box`。该命令还可以通过指定`--box`标志来更新特定的`box`（在活动的`Vagrant`环境之外的）。

`请注意，该命令不会更新已经在运行的Vagrant机器。为了反映box中的变化，您将不得不销毁并重新启动Vagrant机器。`

### 选项

*   `--box VALUE` -要更新的特定`box`的名称。如果未指定此标志，则`Vagrant`将更新活跃的[Vagrant](https://so.csdn.net/so/search?q=Vagrant&spm=1001.2101.3001.7020)环境的`box`。

*   `--provider VALUE`-当`--box`存在时，控制要更新该提供者提供的`box`。当该`box`具有多个提供者时是必要的，否则不是必需的。没有该`--box`是该设置无效。


初始化
---

    vagrant init [name [url]]


通过创建一个初始`Vagrantfile`（如果尚不存在）来初始化当前目录为`Vagrant`环境。

如果给出第一个参数，它将在创建的`Vagrantfile`中预填充`config.vm.box` 。

如果提供了第二个参数，它将在创建的`Vagrantfile`中预填充`config.vm.box_url`。

### 选项

*   `--box-version` -（可选）在`Vagrantfile`中添加 `box` 版本或版本约束。

*   `--force` -如果指定，将覆盖任何现有的 `Vagrantfile`。

*   `--minimal` -如果指定，将创建一个最小的`Vagrantfile`。该`Vagrantfile`不包含普通`Vagrantfile`包含的说明性注释。

*   `--output FILE` -这会将`Vagrantfile`输出到给定的文件。如果它是`-`，则`Vagrantfile`将被发送到`stdout`。

*   `--template FILE` -提供用于生成`Vagrantfile`的自定义`ERB`模板。


### 例子

创建一个基本的`Vagrantfile`：

    $ vagrant init detectionlab/win10


创建一个最小的`Vagrantfile`（无评论或帮助程序）：

    $ vagrant init -m detectionlab/win10


创建一个新的`Vagrantfile`，覆盖当前路径下的文件：

    $ vagrant init -f detectionlab/win10


使用特定的`box`从指定的`box URL`创建`Vagrantfile`：

    $ vagrant init my-company-box https://example.com/my-company.box


创建一个`Vagrantfile`，将`box`锁定到版本约束：

    $ vagrant init --box-version ">1.6" detectionlab/win10


启动
--

    $ vagrant up [name|id]


根据您的 `Vagrantfile` 创建和配置机器 。

这是 `Vagrant` 中最重要的单个命令，因为这是创建任何 `Vagrant` 机器的方式。使用`Vagrant` 的任何人都必须每天使用此命令。

### 选项

*   `name` -`Vagrantfile` 中定义的机器名称

*   `id` -找到的机器`ID` `vagrant global-status`。使用`id`允许您从任何目录启动`vagrant up id`。

*   `--[no-]destroy-on-error` -如果发生致命的意外错误，请销毁新创建的机器。只会发生在第一次执行`vagrant up`时。默认情况下已设置。

*   `--[no-]install-provider` -如果请求的提供者未安装，则`Vagrant`将尝试自动安装它。默认情况下启用。

*   `--[no-]parallel` -如果提供者支持，则并行启动多台机器。

*   `--provider x` -用指定的提供者启动机器。默认情况下，这是`virtualbox`。

*   `--[no-]provision` -强制或阻止预配人员运行。

*   `--provision-with x,y,z` -这只会运行给定的供应者。


关闭
--

    $ vagrant halt [name|id]


关闭 `Vagrant` 正在管理的运行中机器。

`Vagrant` 首先将尝试通过运行操作系统关闭机制来正常关闭计算机。如果失败，或者`--force` 指定了，`Vagrant` 将有效地切断机器的电源。

对于基于 `Linux` 的客户机，`Vagrant` 使用该 `shutdown` 命令正常终止机器。由于操作系统的不同性质，该 `shutdown` 命令可能存在于机器的`$PATH`的不同位置。机器负责正确填充`$PATH`包含 `shutdown` 命令的目录。

### 选项

*   `-f` 或`--force` -不要试图优雅的关闭这台机器。这样可以有效地切断机器的电源。

重新加载
----

    $ vagrant reload [name|id]


等于先执行`halt`，在执行`up`。

为了使`Vagrantfile`中的更改生效，通常需要此命令。对`Vagrantfile`进行任何修改后都应该调用`reload`从新加载。

默认情况下，配置的预配器将不会再次运行。您可以通过指定`--provision`标志来强制供应者重新运行。

### 选项

*   `--provision` -强制供应者运行。

*   `--provision-with x,y,z` -这只会运行给定的供应商。


销毁
--

    $ vagrant destory [name|id]


停止正在运行的`Vagrant`管理的机器，并销毁在机器创建过程中创建的所有资源。运行此命令后，您的机器应保持干净状态，就好像您从未首先创建过机器一样。

### 选项

*   `-f`或`--force` -销毁之前不需要确认。
*   `--[no-]parallel` -如果提供者支持，则并行销毁多台机器。
*   `-g`或`--graceful` -正常关闭机器。

`该destroy命令不会删除用vagrant up安装的机器使用的box。因此，即使您运行vagrant destroy，系统中安装的box仍将存在于硬盘驱动器上。要将机器恢复为vagrant up命令之前的状态，您需要使用vagrant box remove。`

查看状态
----

    $ vagrant status


查看 `Vagrant`正在管理的机器的状态，是正在运行、挂起、未创建等。

