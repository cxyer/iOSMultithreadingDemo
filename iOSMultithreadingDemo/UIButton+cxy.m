//
//  UIButton+cxy.m
//  iOSMultithreadingDemo
//
//  Created by 蔡晓阳 on 2018/7/14.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "UIButton+cxy.h"

@implementation UIButton (cxy)

+ (UIButton *)createNormalButtonWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font color:(UIColor *)color backColor:(UIColor *)backColor {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setBackgroundColor:backColor];
    return button;
}

@end
