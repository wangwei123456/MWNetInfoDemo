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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MWDeviceNetInfo getDeviceIPStr];
    
    [MWDeviceNetInfo  getGateWayForCurWiFi];
}


@end
