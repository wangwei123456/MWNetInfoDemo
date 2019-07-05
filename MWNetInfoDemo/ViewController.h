//
//  ViewController.h
//  MWNetInfoDemo
//
//  Created by 王魏 on 2019/6/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *wifiV6IP;
@property (weak, nonatomic) IBOutlet UITextField *wifiV4IP;
@property (weak, nonatomic) IBOutlet UITextField *cellV6IP;
@property (weak, nonatomic) IBOutlet UITextField *cellV4IP;

@property (weak, nonatomic) IBOutlet UITextField *wifiV6GateWay;
@property (weak, nonatomic) IBOutlet UITextField *wifiV4GateWay;
@property (weak, nonatomic) IBOutlet UITextField *cellV6GateWay;
@property (weak, nonatomic) IBOutlet UITextField *cellV4GateWay;

@end

