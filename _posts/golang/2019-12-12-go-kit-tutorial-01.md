---
layout: post
title: Go kit教程01——基础示例
category: Golang
tags: Golang go-kit
description: Go kit教程01——基础示例
---


本文主要介绍了go-kit的主要组件和设计思路，并带领大家编写了一个基本的rpc示例。

go-kit 教程
=========

[go-kit](https://gokit.io/)不能算是一个框架，可以说是一个Go语言开发用的工具箱/套件。

Go Kit介绍
--------

Go kit 是 Go（golang）包（库）的集合，它可以帮助你构建健壮、可靠、可维护的微服务。Go kit 通过提供成熟的模式和习惯用法来降低 Go 和微服务的风险，这些模式和习惯用法由一大群经验丰富的贡献者编写和维护，并在生产环境中得到验证。

架构和设计
-----

### Go kit关键概念

使用 Go kit 构建的服务分为三层：

1.  传输层（Transport layer）

2.  端点层（Endpoint layer）

3.  服务层（Service layer）


请求在第1层进入服务，向下流到第3层，响应则相反。

这可能需要适应一下，但是据官方的说法，一旦你理解了这些概念，你就会发现 Go kit的设计非常适合现代软件设计。

#### Transports

传输域绑定到具体的传输协议，如 HTTP 或 gRPC。在一个微服务可能支持一个或多个传输协议的世界中，这是非常强大的：你可以在单个微服务中支持原有的 HTTP API 和新增的 RPC 服务。

当实现 REST 式的 HTTP API 时，你的路由是在 HTTP 传输中定义的。最常见的路由定义在 HTTP 路由器函数中，如下所示:

    r.Methods("POST").Path("/profiles/").Handler(httptransport.NewServer(
    		e.PostProfileEndpoint,
    		decodePostProfileRequest,
    		encodeResponse,
    		options...,
    ))


#### Endpoints

端点就像控制器上的动作/处理程序; 它是安全性和抗脆弱性逻辑的所在。如果实现两种传输(HTTP 和 gRPC) ，则可能有两种将请求发送到同一端点的方法。

#### Services

服务（指Go kit中的service层）是实现所有业务逻辑的地方。服务层通常将多个端点粘合在一起。在 Go kit 中，服务层通常被抽象为接口，这些接口的实现包含业务逻辑。Go kit 服务层应该努力遵守整洁架构或六边形架构。也就是说，业务逻辑不需要了解端点（尤其是传输域）概念：你的服务层不应该关心HTTP 头或 gRPC 错误代码。

#### Middlewares

Go kit 试图通过使用中间件（或装饰器）模式来执行严格的关注分离（separation of concerns）。中间件可以包装端点或服务以添加功能，比如日志记录、速率限制、负载平衡或分布式跟踪。围绕一个端点或服务链接多个中间件是很常见的。

将所有这些概念放在一起，我们可以看到 Go kit 构建的微服务就像洋葱一样有许多层。

![gokit onion](/assets/image/onion.png)

这些层可以分组到我们的三个域中：

*   最内层的**服务（service）**域是所有内容都基于特定服务定义的地方，也是实现所有业务逻辑的地方。

*   中间**端点（endpoint）**域是将服务的每个方法抽象为通用 [endpoint.Endpoint](https://godoc.org/github.com/go-kit/kit/endpoint#Endpoint)以及实现安全性和抗脆弱性逻辑的位置。

*   最外层的**传输（transport）**域是端点绑定到 HTTP 或 gRPC 等具体传输的地方。


你可以通过为服务定义接口并提供具体的实现来实现核心业务逻辑。然后，编写服务中间件来提供额外的功能，比如日志记录、分析、检测ーー任何需要了解业务领域知识的东西。

Go kit 提供端点和传输域中间件，用于诸如速率限制、断路、负载平衡和分布式跟踪等功能ーー所有这些功能通常与你的业务域无关。

简而言之，Go kit 试图通过精心使用中间件（或装饰器）模式来强制执行严格的关注分离（**separation of concerns**）。

快速开始
----

接下来就演示如何使用 Go kit 快速实现一个微服务。

在本机上新建项目目录`addsrv1`，并在项目目录下执行`go mod init addsrv`完成项目的初始化。

### 业务逻辑

服务从业务逻辑开始写起。在 Go kit 中，我们将服务建模为一个接口。

    // AddService 把两个东西加到一起
    type AddService interface {
    	Sum(ctx context.Context, a, b int) (int, error)
    	Concat(ctx context.Context, a, b string) (string, error)
    }


这个接口有一个实现。

    type addService struct{}
    
    const maxLen = 10
    
    var (
    	// ErrTwoZeroes  Sum方法的业务规则不能对两个0求和
    	ErrTwoZeroes = errors.New("can't sum two zeroes")
    
    	// ErrIntOverflow Sum参数越界
    	ErrIntOverflow = errors.New("integer overflow")
    
    	// ErrTwoEmptyStrings Concat方法业务规则规定参数不能是两个空字符串.
    	ErrTwoEmptyStrings = errors.New("can't concat two empty strings")
    
    	// ErrMaxSizeExceeded Concat方法的参数超出范围
    	ErrMaxSizeExceeded = errors.New("result exceeds maximum size")
    )
    
    // Sum 对两个数字求和，实现AddService。
    func (s addService) Sum(_ context.Context, a, b int) (int, error) {
    	if a == 0 && b == 0 {
    		return 0, ErrTwoZeroes
    	}
    	if (b > 0 && a > (math.MaxInt-b)) || (b < 0 && a < (math.MinInt-b)) {
    		return 0, ErrIntOverflow
    	}
    	return a + b, nil
    }
    
    // Concat 连接两个字符串，实现AddService。
    func (s addService) Concat(_ context.Context, a, b string) (string, error) {
    	if a == "" && b == "" {
    		return "", ErrTwoEmptyStrings
    	}
    	if len(a)+len(b) > maxLen {
    		return "", ErrMaxSizeExceeded
    	}
    	return a + b, nil
    }


### 请求和响应

在 Go kit 中，主要的消息模式是 RPC。因此，我们接口中的每个方法都将被建模为一个远程过程调用。对于每个方法，我们定义**请求和响应**结构体，分别捕获所有的输入和输出参数。

    // SumRequest Sum方法的参数.
    type SumRequest struct {
    	A int `json:"a"`
    	B int `json:"b"`
    }
    
    // SumResponse Sum方法的响应
    type SumResponse struct {
    	V   int    `json:"v"`
    	Err string `json:"err,omitempty"`
    }
    
    // ConcatRequest Concat方法的参数.
    type ConcatRequest struct {
    	A string `json:"a"`
    	B string `json:"b"`
    }
    
    // ConcatResponse  Concat方法的响应.
    type ConcatResponse struct {
    	V   string `json:"v"`
    	Err string `json:"err,omitempty"`
    }


### Endpoints

Go kit 通过一个称为**endpoint**的抽象提供了许多功能。``Endpoint`的定义如下：

    type Endpoint func(ctx context.Context, request interface{}) (response interface{}, err error)


它表示单个 RPC。也就是说，我们的服务接口中只有一个方法。我们将编写简单的适配器来将服务的每个方法转换为一个端点。每个适配器接受一个 AddService，并返回与其中一个方法对应的端点。

    import "github.com/go-kit/kit/endpoint"
    
    func makeSumEndpoint(svc AddService) endpoint.Endpoint {
    	return func(ctx context.Context, request interface{}) (interface{}, error) {
    		req := request.(SumRequest)
    		v, err := svc.Sum(ctx, req.A, req.B)
    		if err != nil {
    			return SumResponse{V: v, Err: err.Error()}, nil
    		}
    		return SumResponse{V: v}, nil
    	}
    }
    
    func makeConcatEndpoint(svc AddService) endpoint.Endpoint {
    	return func(ctx context.Context, request interface{}) (interface{}, error) {
    		req := request.(ConcatRequest)
    		v, err := svc.Concat(ctx, req.A, req.B)
    		if err != nil {
    			return ConcatResponse{V: v, Err: err.Error()}, nil
    		}
    		return ConcatResponse{V: v}, nil
    	}
    }


### Transports

现在我们需要将编写的服务公开给外部世界，这样就可以调用它了。Go kit 开箱即用的支持 gRPC、Thrift或者基于HTTP的JSON。

这里我们先演示如何使用HTTP之上的JSON作为传输协议。

    import httptransport "github.com/go-kit/kit/transport/http"
    
    func decodeSumRequest(_ context.Context, r *http.Request) (interface{}, error) {
    	var request SumRequest
    	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
    		return nil, err
    	}
    	return request, nil
    }
    
    func decodeCountRequest(_ context.Context, r *http.Request) (interface{}, error) {
    	var request ConcatRequest
    	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
    		return nil, err
    	}
    	return request, nil
    }
    
    func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
    	return json.NewEncoder(w).Encode(response)
    }
    
    func main() {
    	svc := addService{}
    
    	sumHandler := httptransport.NewServer(
    		makeSumEndpoint(svc),
    		decodeSumRequest,
    		encodeResponse,
    	)
    
    	concatHandler := httptransport.NewServer(
    		makeConcatEndpoint(svc),
    		decodeCountRequest,
    		encodeResponse,
    	)
    
    	http.Handle("/sum", sumHandler)
    	http.Handle("/concat", concatHandler)
    	log.Fatal(http.ListenAndServe(":8080", nil))
    }


### 运行

在项目目录下编译得到可执行文件并运行，服务会在本机的`8080`端口启动。我们使用curl或postman测试我们的服务。

    ❯ curl -XPOST -d'{"a":1,"b":2}' localhost:8080/sum
    {"v":3}
    ❯ curl -XPOST -d'{"a":"你好","b":"qimi"}' localhost:8080/concat
    {"v":"你好qimi"}


