//
//  ZHHLoadingAnimSystem.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimSystem.h"
#import <objc/runtime.h>

/// 关联对象 key：仅本类使用，与其它动画文件互不干扰。
static char kZHHLoadingAnimSystemKey;

@implementation ZHHLoadingAnimSystem

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimSystemKey);
    if (!tracked.count) {
        return;
    }
    // 遍历记录：子视图停转并 remove；子图层去动画并 removeFromSuperlayer
    for (id obj in tracked) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)obj stopAnimating];
            [(UIView *)obj removeFromSuperview];
        } else if ([obj isKindOfClass:[CALayer class]]) {
            CALayer *L = obj;
            [L removeAllAnimations];
            [L removeFromSuperlayer];
        }
    }
    [tracked removeAllObjects];
}

+ (void)addToView:(UIView *)view color:(UIColor *)color {
    // 再次添加前先清掉本类旧实例，避免叠两层
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimSystemKey);
    if (a.count) {
        for (id obj in a) {
            if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
                [(UIActivityIndicatorView *)obj stopAnimating];
                [(UIView *)obj removeFromSuperview];
            } else if ([obj isKindOfClass:[CALayer class]]) {
                CALayer *L = obj;
                [L removeAllAnimations];
                [L removeFromSuperlayer];
            }
        }
        [a removeAllObjects];
    }

    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    ai.color = color;
    ai.hidesWhenStopped = NO;
    ai.frame = view.bounds;
    ai.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [ai startAnimating];
    [view addSubview:ai];

    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimSystemKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimSystemKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tracked addObject:ai];
}

@end
