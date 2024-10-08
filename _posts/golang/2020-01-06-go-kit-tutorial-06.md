---
layout: post
title: Go kit教程06——服务发现和负载均衡
category: Golang
tags: Golang go-kit
description: Go kit教程06——服务发现和负载均衡
---

本文主要介绍了如何使用 Go kit 实现基于consul的服务发现和负载均衡。


在上一篇中，我们在项目中调用了其他的服务（1个实例），但实际生产环境下可能会有很多个服务实例。我们需要通过某种机制去实现服务发现和负载均衡。如果这些实例中的任何一个开始出现问题，我们希望在不影响我们自己服务的可靠性的情况下处理这个问题。

服务发现
----

### Endpointer

Go kit 为不同的服务发现系统（eureka、zookeeper、consul、etcd等）提供适配器，`Endpointer`负责监听服务发现系统，并根据需要生成一组相同的端点

    type Endpointer interface {
    	Endpoints() ([]endpoint.Endpoint, error)
    }


Go kit 提供了工厂函数——`Factory`， 它是一个将实例字符串(例如host:port)转换为特定端点的函数。提供多个端点的实例需要多个工厂函数。工厂函数还返回一个当实例消失并需要清理时调用的`io.Closer`。

    type Factory func(instance string) (endpoint.Endpoint, io.Closer, error)


例如，我们可以定义如下工厂函数，它会根据传入的实例地址创建一个gRPC客户端endpoint。

    func factory(instance string) (endpoint.Endpoint, io.Closer, error) {
    	conn, err := grpc.Dial(instance, grpc.WithInsecure())
    	if err != nil {
    		return nil, nil, err
    	}
    
    	e := makeTrimEndpoint(conn)
    	return e, conn, err
    }


### Balancer

现在我们已经有了一组端点，我们需要从中选择一个。负载均衡器包装订阅者，并从多个端点中选择一个端点。

    type Balancer interface {
    	Endpoint() (endpoint.Endpoint, error)
    }


Go Kit 提供了一些基本的负载均衡器，如果你想要更高级的启发式方法，那么可以编写自己的负载均衡器。

下面的示例代码演示了如何使用`RoundRobin` 策略。

    import "github.com/go-kit/kit/sd/lb"
    
    balancer := lb.NewRoundRobin(endpointer)


### 重试

重试策略包装负载均衡器，并返回可用的端点。重试策略将重试失败的请求，直到达到最大尝试或超时为止。

    func Retry(max int, timeout time.Duration, lb Balancer) endpoint.Endpoint


下面的示例代码演示了如何使用Go kit中的重试功能。

    import "github.com/go-kit/kit/sd/lb"
    
    retry := lb.Retry(3, 500*time.Millisecond, balancer)


### 基于consul的服务发现完整示例

    // getTrimServiceFromConsul 基于consul的服务发现
    func getTrimServiceFromConsul(consulAddr string, srvName string, tags []string, logger log.Logger) (endpoint.Endpoint, error) {
    	consulConfig := api.DefaultConfig()
    	consulConfig.Address = consulAddr
    
    	consulClient, err := apiconsul.NewClient(consulConfig)
    	if err != nil {
    		return nil, err
    	}
    
    	sdClient := sdconsul.NewClient(consulClient)
    	var passingOnly = true
    	instancer := sdconsul.NewInstancer(sdClient, logger, srvName, tags, passingOnly)
    	endpointer := sd.NewEndpointer(instancer, factory, logger)
    	balancer := lb.NewRoundRobin(endpointer)
    	retryMax := 3
    	retryTimeout := 500 * time.Millisecond
    	retry := lb.Retry(retryMax, retryTimeout, balancer)
    	return retry, nil
    }
    
    func factory(instance string) (endpoint.Endpoint, io.Closer, error) {
    	conn, err := grpc.Dial(instance, grpc.WithInsecure())
    	if err != nil {
    		return nil, nil, err
    	}
    
    	e := makeTrimEndpoint(conn)
    	return e, conn, err
    }


将上一篇教程的`main`函数中获取`trimEndpoint`的方式改为从`consul`获取。

    // main.go
    
    // 基于 consul 对 trim_service 做服务发现
    trimEndpoint, err := getTrimServiceFromConsul("localhost:8500", "trim_service", nil, logger)
    if err != nil {
    	fmt.Printf("connect %s failed, err: %v", *trimAddr, err)
    	return
    }


### trim服务

对 trim 服务做适当改造，以支持在程序启动后将当前服务实例注册到consul，以及程序退出时从consul注销服务。

    package main
    
    import (
    	"context"
    	"flag"
    	"fmt"
    	"net"
    	"os"
    	"os/signal"
    	"strings"
    	"syscall"
    
    	"trim_service/pb"
    
    	apiconsul "github.com/hashicorp/consul/api"
    	"google.golang.org/grpc"
    )
    
    const serviceName = "trim_service"
    
    var (
    	port       = flag.Int("port", 8975, "service port")
    	consulAddr = flag.String("consul", "localhost:8500", "consul address")
    )
    
    // trim service
    
    type server struct {
    	pb.UnimplementedTrimServer
    }
    
    // TrimSpace 去除字符串参数中的空格
    func (s *server) TrimSpace(_ context.Context, req *pb.TrimRequest) (*pb.TrimResponse, error) {
    	ov := req.GetS()
    	v := strings.ReplaceAll(ov, " ", "")
    	fmt.Printf("ov:%s v:%v\n", ov, v)
    	return &pb.TrimResponse{S: v}, nil
    }
    
    func main() {
    	flag.Parse()
    	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
    	if err != nil {
    		fmt.Printf("failed to listen: %v", err)
    		return
    	}
    	s := grpc.NewServer()
    	pb.RegisterTrimServer(s, &server{})
    
    	// 服务注册
    	cc, err := NewConsulClient(*consulAddr)
    	if err != nil {
    		fmt.Printf("failed to NewConsulClient: %v", err)
    		return
    	}
    	ipInfo, err := getOutboundIP()
    	if err != nil {
    		fmt.Printf("getOutboundIP failed, err:%v\n", err)
    		return
    	}
    	if err := cc.RegisterService(serviceName, ipInfo.String(), *port); err != nil {
    		fmt.Printf("regToConsul failed, err:%v\n", err)
    		return
    	}
    	go func() {
    		if err := s.Serve(lis); err != nil {
    			fmt.Printf("failed to serve: %v", err)
    			return
    		}
    	}()
    
    	quit := make(chan os.Signal, 1)
    	signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)
    	<-quit
    	// 退出时注销服务
    	cc.Deregister(fmt.Sprintf("%s-%s-%d", serviceName, ipInfo.String(), *port))
    }
    
    // consul reg&de
    type consulClient struct {
    	client *apiconsul.Client
    }
    
    // NewConsulClient 新建consulClient
    func NewConsulClient(consulAddr string) (*consulClient, error) {
    	cfg := apiconsul.DefaultConfig()
    	cfg.Address = consulAddr
    	client, err := apiconsul.NewClient(cfg)
    	if err != nil {
    		return nil, err
    	}
    	return &consulClient{client}, nil
    }
    
    // RegisterService 服务注册
    func (c *consulClient) RegisterService(serviceName, ip string, port int) error {
    	srv := &apiconsul.AgentServiceRegistration{
    		ID:      fmt.Sprintf("%s-%s-%d", serviceName, ip, port), // 服务唯一ID
    		Name:    serviceName,                                    // 服务名称
    		Tags:    []string{"q1mi", "trim"},                       // 为服务打标签
    		Address: ip,
    		Port:    port,
    	}
    	return c.client.Agent().ServiceRegister(srv)
    }
    
    // Deregister 注销服务
    func (c *consulClient) Deregister(serviceID string) error {
    	return c.client.Agent().ServiceDeregister(serviceID)
    }
    
    // getOutboundIP 获取本机的出口IP
    func getOutboundIP() (net.IP, error) {
    	conn, err := net.Dial("udp", "8.8.8.8:80")
    	if err != nil {
    		return nil, err
    	}
    	defer conn.Close()
    	localAddr := conn.LocalAddr().(*net.UDPAddr)
    	return localAddr.IP, nil
    }


