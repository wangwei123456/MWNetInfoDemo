//
//  MWDeviceNetInfo.m
//  MWNetInfoDemo
//
//  Created by 王魏 on 2019/6/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

#import "MWDeviceNetInfo.h"

#include <resolv.h>
#include <dns.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <sys/sysctl.h>
#import <netinet/in.h>

#include "Route.h"

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a)-1) | (sizeof(long) - 1))) : sizeof(long))


//iPhone设备上蜂窝网络名称
//也可能为 pdp_ip1 pdp_ip2 pdp_ip3 pdp_ip4 双卡双待设备就有不同的名称
#define CELLULAR_NET_NAME0 @"pdp_ip0"
#define CELLULAR_NET_NAME1 @"pdp_ip1"

//iPhone设备上WI-FI名称
//其他设备不一定是这个 可能是en1 en2 en3 ，Mac、 windows、Linux、unix都可能不一样
#define WIFI_NET_NAME     @"en0"

//VPN名称 utun2 utun3
#define VPN_NET_NAME      @"utun0"


//其他名称     lo0：本机端口名称
//            ap1：接入点使用的接口
//           ipsec0：
//           awdl0：苹果无线直接链接接口


@implementation MWDeviceNetInfo

+ (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    
    NSString *address = nil;
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    return address;
}


+ (NSString *)formatIPV4Address:(struct in_addr)ipv4Addr{
    NSString *address = nil;
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    return address;
}
+ (NSDictionary *)getifaddrsInfos
{

    NSMutableDictionary * ifaddrsInfos = [NSMutableDictionary dictionaryWithCapacity:0];

    struct ifaddrs *if_addrs = NULL;
    struct ifaddrs *temp_addrs = NULL;
    if(getifaddrs(&if_addrs) != 0){
//        NSLog(@"getifaddrsInfos failed");
        return ifaddrsInfos;//获取失败
    }
    //这样处理是为了防止内存泄漏 if_addrs不是真正的链表, 仅是伪链表
    //参考http://xinzhiwen198941-163-com.iteye.com/blog/994704
    temp_addrs = if_addrs;
    
    while (temp_addrs != NULL) {
        
        NSString * ifaName = [NSString stringWithUTF8String:temp_addrs->ifa_name];
//        NSLog(@"ifaName:%@",ifaName);
        
        NSString * addressValue = nil;
        NSString * key = nil;
        if (temp_addrs->ifa_addr->sa_family == AF_INET){
            //IPV4地址 32bit
            addressValue = [self formatIPV4Address:((struct sockaddr_in *)temp_addrs->ifa_addr)->sin_addr];
//            NSLog(@"IPV4:%@",addressValue);
            key = [NSString stringWithFormat:@"%@_IPV4",ifaName];
            
        }else if (temp_addrs->ifa_addr->sa_family == AF_INET6){
            //IPV6地址 128bit
            addressValue = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addrs->ifa_addr)->sin6_addr];
//            NSLog(@"IPV6:%@",addressValue);
            key = [NSString stringWithFormat:@"%@_IPV6",ifaName];
        }
        
        if (addressValue && key) {
            [ifaddrsInfos setValue:addressValue forKey:key];
        }
        temp_addrs = temp_addrs->ifa_next;
    }
    
    freeifaddrs(if_addrs);
    return ifaddrsInfos;
}
+ (NSString *)getDeviceIPStr{
    
    NSString * resultIpStr = nil;

    
    NSString * CELLULAR_IPV4_KEY = [NSString stringWithFormat:@"%@_IPV4",CELLULAR_NET_NAME0];
    NSString * CELLULAR_IPV6_KEY = [NSString stringWithFormat:@"%@_IPV6",CELLULAR_NET_NAME0];
    NSString * WIFI_IPV4_KEY = [NSString stringWithFormat:@"%@_IPV4",WIFI_NET_NAME];
    NSString * WIFI_IPV6_KEY = [NSString stringWithFormat:@"%@_IPV6",WIFI_NET_NAME];
    
    //排定搜索顺序
    NSArray * keys = @[WIFI_IPV6_KEY,WIFI_IPV4_KEY,CELLULAR_IPV4_KEY,CELLULAR_IPV6_KEY];
    
    
    NSDictionary * addrsDic = [self getifaddrsInfos];
    
    for (NSString * key in keys) {
        resultIpStr = [addrsDic objectForKey:key];
        if (resultIpStr) {
            break;
        }
    }
    NSLog(@"getDeviceIP:%@",resultIpStr);
    return resultIpStr;
}

+ (NSString *)getDeviceIPStrWithNetType:(MW_NET_TYPE)netType ipType:(MW_IP_TYPE)ipType{
    
    NSString * resultIpStr = nil;
    
    
    NSString * CELLULAR_IPV4_KEY = [NSString stringWithFormat:@"%@_IPV4",CELLULAR_NET_NAME0];
    NSString * CELLULAR_IPV6_KEY = [NSString stringWithFormat:@"%@_IPV6",CELLULAR_NET_NAME0];
    NSString * WIFI_IPV4_KEY = [NSString stringWithFormat:@"%@_IPV4",WIFI_NET_NAME];
    NSString * WIFI_IPV6_KEY = [NSString stringWithFormat:@"%@_IPV6",WIFI_NET_NAME];
    //排定搜索顺序
    NSArray * keys = nil;
    if (netType == MW_NET_TYPE_CELLULAR && ipType == MW_IP_TYPE_IPV4) {
        
         keys = @[CELLULAR_IPV4_KEY];
    }else if (netType == MW_NET_TYPE_CELLULAR && ipType == MW_IP_TYPE_IPV6){
        
         keys = @[CELLULAR_IPV6_KEY];
    }else if (netType == MW_NET_TYPE_WIFI && ipType == MW_IP_TYPE_IPV4){
        
         keys = @[WIFI_IPV4_KEY];
    }else if (netType == MW_NET_TYPE_WIFI && ipType == MW_IP_TYPE_IPV6){
        
         keys = @[WIFI_IPV6_KEY];
    }
    
   
    NSDictionary * addrsDic = [self getifaddrsInfos];
    
    for (NSString * key in keys) {
        resultIpStr = [addrsDic objectForKey:key];
        if (resultIpStr) {
            break;
        }
    }
    NSLog(@"getDeviceIPStrWithCellular:%@",resultIpStr);
    return resultIpStr;
    
}


+ (NSString *)getGateWayForCurWiFi{
    
    NSString * resultGatewayStr = nil;
    
    NSString * gatewayIpv4Str = [self getGateWayForCurWiFi:MW_IP_TYPE_IPV4];
    NSString * gatewayIpv6Str = [self getGateWayForCurWiFi:MW_IP_TYPE_IPV6];
    if (gatewayIpv6Str) {
        resultGatewayStr = gatewayIpv6Str;
    }else{
        resultGatewayStr = gatewayIpv4Str;
    }
    NSLog(@"getGateWayForCurWiFi:%@",resultGatewayStr);
    return resultGatewayStr;
}

+ (NSString *)getGateWayForCurWiFi:(MW_IP_TYPE)ipType{
    
    NSString * gatewayStr = nil;
    
    /* net.route.0.inet.flags.gateway */
    
    int mib[6] = {0};
   
    if (ipType == MW_IP_TYPE_IPV4) {
        
        mib[0] = CTL_NET;
        mib[1] = PF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_INET;
        mib[4] = NET_RT_FLAGS;
        mib[5] = RTF_GATEWAY;
        
    }else if(ipType == MW_IP_TYPE_IPV6){
        
        mib[0] = CTL_NET;
        mib[1] = PF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_INET6;
        mib[4] = NET_RT_FLAGS;
        mib[5] = RTF_GATEWAY;
        
    }
    
     //IPV4 路由网关
     //    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
     //        NET_RT_FLAGS, RTF_GATEWAY};
    
     //IPV6 路由网关
     //    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET6,
     //        NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt = NULL;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    
    //此函数详解参照https://nanxiao.me/freebsd-sysctl/
    //    https://blog.csdn.net/xuanzhuanshuixing/article/details/6031832
    
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return gatewayStr;
    }
    if(l>0) {
        buf = (char *)malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return gatewayStr;
        }
        //
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY)))
             {

                 
                 char name[IF_NAMESIZE] = {0};
                 //获取网卡名称
                 if_indextoname(rt->rtm_index, name);
                 // printf("name:%s\n",name);
                 
                 if (ipType == MW_IP_TYPE_IPV4) {
                     if (sa_tab[RTAX_DST]->sa_family == AF_INET && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                         
                         if (!strcmp(name, "en0")) {//Wi-Fi
                             
                             gatewayStr = [self formatIPV4Address:(((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr)];
                             
                             break;
                         }
                     }
                     
                     
                 }else if(ipType == MW_IP_TYPE_IPV6){
                     if (sa_tab[RTAX_DST]->sa_family == AF_INET6 && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET6) {
                         
                         if (!strcmp(name, "en0")) {//Wi-Fi

                            gatewayStr = [self formatIPV6Address:(((struct sockaddr_in6 *)(sa_tab[RTAX_GATEWAY]))->sin6_addr)];
                             
                             break;
                         }
                     }
                     
                 }
                 
                 
               
                
            }
        }
        free(buf);
    }
    
    return gatewayStr;
    
}

@end
