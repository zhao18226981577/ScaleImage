//
//  ViewController.m
//  ScaleImage
//
//  Created by 精智 on 17/5/25.
//  Copyright © 2017年 精智. All rights reserved.
//

#import "ViewController.h"
#import "PhotoScaleView.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)clickButton:(UIButton *)sender {
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect rect1 = [sender convertRect:sender.frame fromView:self.view];     //获取button在contentView的位置
    CGRect rect2 = [sender convertRect:rect1 toView:keyWindow];         //获取button在window的位置
    CGRect rect3 = CGRectInset(rect2, -0.5 * 8, -0.5 * 8);          //扩大热区
    PhotoScaleView *view = [[PhotoScaleView alloc] initWiththumbnail:sender.imageView.image fromRect:rect3];
    [keyWindow addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
