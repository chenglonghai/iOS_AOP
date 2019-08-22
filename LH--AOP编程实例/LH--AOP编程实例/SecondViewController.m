//
//  SecondViewController.m
//  LH--AOP编程实例
//
//  Created by chenlonghai on 2019/8/21.
//  Copyright © 2019 chenlonghai. All rights reserved.
//

#import "SecondViewController.h"


@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)lh_viewDidLoad{

    NSLog(@"lh_viewDidLoad");
    self.view.backgroundColor = [UIColor yellowColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSLog(@"SecondViewController->%s", __func__);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
