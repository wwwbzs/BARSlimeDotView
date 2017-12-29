//
//  ViewController.m
//  BARSlimeDotView
//
//  Created by Barray on 2017/12/29.
//  Copyright © 2017年 Barray. All rights reserved.
//

#import "ViewController.h"
#import "BARSlimeDotView.h"
#import "BARSlimeDotView-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BARSlimeDotView_Swift *slimeView_Swift = [[BARSlimeDotView_Swift alloc] initWithFrame:CGRectMake(100, 300, 130, 130)];
    slimeView_Swift.backgroundColor = [UIColor greenColor];
    [self.view addSubview:slimeView_Swift];
    
    BARSlimeDotView *slimeView = [[BARSlimeDotView alloc] initWithFrame: CGRectMake(100, 100, 130, 130)];
    slimeView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview: slimeView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
