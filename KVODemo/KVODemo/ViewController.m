//
//  ViewController.m
//  KVODemo
//
//  Created by Jerod on 2020/11/3.
//

#import "ViewController.h"
#import "BBViewController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.lightGrayColor;
    self.navigationItem.title = @"首页";
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BBViewController * b = [BBViewController new];
    [self.navigationController pushViewController:b animated:YES];
}



@end
