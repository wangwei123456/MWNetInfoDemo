//
//  ViewController.m
//  MWNetInfoDemo
//
//  Created by 王魏 on 2019/6/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

#import "ViewController.h"

#import "NetInfo/MWDeviceNetInfo.h"

@interface ViewController ()
{
    NSString * _wifiV6IpStr;
    NSString * _wifiV4IpStr;
    NSString * _cellV6IpStr;
    NSString * _cellV4IpStr;

    NSString * _wifiV6GatewayStr;
    NSString * _wifiV4GatewayStr;
    NSString * _cellV6GatewayStr;
    NSString * _cellV4GatewayStr;

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

}
- (IBAction)getNetInfo:(id)sender {
    
    
    NSLog(@"getDeviceIPStr====:%@",[MWDeviceNetInfo getDeviceIPStr]);
    
    _wifiV6IpStr = [MWDeviceNetInfo getDeviceIPStrWithNetType:MW_NET_TYPE_WIFI ipType:MW_IP_TYPE_IPV6];
    _wifiV4IpStr = [MWDeviceNetInfo getDeviceIPStrWithNetType:MW_NET_TYPE_WIFI ipType:MW_IP_TYPE_IPV4];
    _cellV6IpStr = [MWDeviceNetInfo getDeviceIPStrWithNetType:MW_NET_TYPE_CELLULAR ipType:MW_IP_TYPE_IPV6];
    _cellV4IpStr = [MWDeviceNetInfo getDeviceIPStrWithNetType:MW_NET_TYPE_CELLULAR ipType:MW_IP_TYPE_IPV4];

    
    
    _wifiV6GatewayStr = [MWDeviceNetInfo  getGateWayForCurWiFi:MW_IP_TYPE_IPV6];
    _wifiV4GatewayStr = [MWDeviceNetInfo  getGateWayForCurWiFi:MW_IP_TYPE_IPV4];
    
    
    
    [self reloadUI];
}

- (void)reloadUI{
    
    _wifiV6IP.text = _wifiV6IpStr;
    _wifiV4IP.text = _wifiV4IpStr;
    _cellV6IP.text = _cellV6IpStr;
    _cellV4IP.text = _cellV4IpStr;
    
    _wifiV6GateWay.text = _wifiV6GatewayStr;
    _wifiV4GateWay.text = _wifiV4GatewayStr;
    _cellV6GateWay.text = _cellV6GatewayStr;
    _cellV4GateWay.text = _cellV4GatewayStr;

}

@end
