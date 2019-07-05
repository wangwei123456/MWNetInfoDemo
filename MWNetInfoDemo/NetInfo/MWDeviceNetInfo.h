//
//  MWDeviceNetInfo.h
//  MWNetInfoDemo
//
//  Created by 王魏 on 2019/6/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    MW_NET_TYPE_CELLULAR,
    MW_NET_TYPE_WIFI,
} MW_NET_TYPE;

typedef enum : NSUInteger {
    MW_IP_TYPE_IPV4,
    MW_IP_TYPE_IPV6,
} MW_IP_TYPE;

@interface MWDeviceNetInfo : NSObject


//IMPORTANT:这些接口都是针对iPhone、iPad等移动设备,Mac或者其他机器上不能使用，因为这些设备的蜂窝、Wi-Fi网卡名称可能都不一样



/**
 获取设备当前连接网络的IP（蜂窝网络、WI-FI、IPV4、IPV6均支持）
 
 检索顺序为WI-FI的IPV6、WI-FI的IPV4、蜂窝网络的IPV4、蜂窝网络的IPV6,可使用[getDeviceIPStrWithNetType: ipType:]精确获取所需要的IP地址
 
 NOTE:不管是什么网络下的IPV4、IPV6地址 都可能不止一个，这里只会获取网络接口链表最前面的IP地址
 对于双卡双待设备蜂窝网络下IP地址 只会获取主卡网络的IP地址，需要获取副卡的IP地址，请自行修改代码，其网卡名称可能为"pdp_ip1"
 
 @return 设备IP地址字符串 可能为空字符串
 */
+ (NSString *)getDeviceIPStr;




/**
 获取设备当前连接网络的IP（蜂窝网络、WI-FI、IPV4、IPV6均支持）

 @param netType YES只获取蜂窝网络下的IP地址 NO获取WIFI下的IP地址
 @param ipType YES只获IPV4下的IP地址 NO获取IPV6下的IP地址
 @return 设备IP地址字符串 可能为空字符串
 */
+ (NSString *)getDeviceIPStrWithNetType:(MW_NET_TYPE)netType ipType:(MW_IP_TYPE)ipType;






/**
  获取当前连接的wifi的网关地址 iPhone手机如果连接到不可用的wifi时 可能不会显示wifi连接状态 依然显示4G 此时获取的网关并不是wifi的网关 而是蜂窝网络的网关  如果App需要与硬件的AP模式配合使用  获取网关就会有问题 所以我们需要获取当前连接wifi的网关地址 这样才能正常通信
 
 NOTE:IPV6网络下只会获取IPV6的网关地址，需要在IPV6网络下获取IPV4的网关地址请自行修改
      IPV4网络下 只能获取IPV4的网关地址
 
      蜂窝网络下会返回nil 需要获取蜂窝网络下的网关地址请自行修改
 
 */
+ (NSString *)getGateWayForCurWiFi;

+ (NSString *)getGateWayForCurWiFi:(MW_IP_TYPE)ipType;

@end

NS_ASSUME_NONNULL_END
