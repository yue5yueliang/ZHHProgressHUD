//
//  ZHHLoadingAnimAsymmetricDots.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimAsymmetricDots.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimAsymmetricDotsKey;

@implementation ZHHLoadingAnimAsymmetricDots

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimAsymmetricDotsKey);
    if (!tracked.count) {
        return;
    }
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
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimAsymmetricDotsKey);
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

    CGSize sz = view.bounds.size;
    NSTimeInterval d = 1.25;
    CGFloat spacing = 3.0;

    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.keyTimes = @[@0, @0.5, @1];
    scaleAnim.values = @[@1, @0.4, @1];
    scaleAnim.duration = d;

    CAKeyframeAnimation *opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.keyTimes = @[@0, @0.5, @1];
    opacityAnim.values = @[@1, @0.3, @1];
    opacityAnim.duration = d;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.duration = d;
    group.repeatCount = HUGE_VALF;
    group.removedOnCompletion = NO;
    group.animations = @[scaleAnim, opacityAnim];

    CGFloat dotR = (sz.width - 4 * spacing) / 3.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(dotR * 0.5, dotR * 0.5) radius:dotR * 0.5 startAngle:0 endAngle:(CGFloat)(M_PI * 2) clockwise:NO];

    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimAsymmetricDotsKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimAsymmetricDotsKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    CFTimeInterval beginTime = CACurrentMediaTime();
    NSArray *beginTimes = @[@0.84, @0.72, @0.6, @0.48, @0.36, @0.24, @0.12, @0];
    CGFloat radiusX = (sz.width - dotR) * 0.5;

    for (NSInteger index = 0; index < 8; index++) {
        CGFloat angle = (CGFloat)(M_PI_4 * index);
        CAShapeLayer *L = [CAShapeLayer layer];
        L.path = path.CGPath;
        L.fillColor = color.CGColor;
        // 圆心落在大圆上，frame 左上角由几何换算
        L.frame = CGRectMake(radiusX * (cosf(angle) + 1), radiusX * (sinf(angle) + 1), dotR, dotR);
        CAAnimationGroup *copy = [group copy];
        copy.beginTime = beginTime - [beginTimes[index] doubleValue];
        [L addAnimation:copy forKey:@"zhh.asym"];
        [view.layer addSublayer:L];
        [tracked addObject:L];
    }
}

@end
