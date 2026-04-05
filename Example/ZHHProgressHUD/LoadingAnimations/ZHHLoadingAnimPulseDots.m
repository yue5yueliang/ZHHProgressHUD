//
//  ZHHLoadingAnimPulseDots.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimPulseDots.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimPulseDotsKey;

@implementation ZHHLoadingAnimPulseDots

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimPulseDotsKey);
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
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimPulseDotsKey);
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
    CGFloat spacing = 6.0;
    NSInteger count = 3;
    // 总宽减去间距后均分给每个圆点外接正方形边长
    CGFloat radius = (sz.width - spacing * (count - 1)) / count;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius * 0.5, radius * 0.5) radius:radius * 0.5 startAngle:(CGFloat)(-M_PI_2) endAngle:(CGFloat)(M_PI * 1.5) clockwise:YES];

    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.keyTimes = @[@0, @0.5, @1];
    scaleAnim.timingFunctions = @[
        [CAMediaTimingFunction functionWithControlPoints:0.2f :0.68f :0.18f :1.08f],
        [CAMediaTimingFunction functionWithControlPoints:0.2f :0.68f :0.18f :1.08f]
    ];
    scaleAnim.values = @[@1, @0.45, @1];
    scaleAnim.duration = d;
    scaleAnim.repeatCount = HUGE_VALF;
    scaleAnim.removedOnCompletion = NO;

    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimPulseDotsKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimPulseDotsKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    CFTimeInterval beginTime = CACurrentMediaTime();
    NSArray *beginTimes = @[@0.36, @0.24, @0.12];
    for (NSInteger i = 0; i < count; i++) {
        CAShapeLayer *L = [CAShapeLayer layer];
        L.frame = CGRectMake((radius + spacing) * i, (sz.height - radius) * 0.5, radius, radius);
        L.path = path.CGPath;
        L.fillColor = color.CGColor;
        CAKeyframeAnimation *copy = [scaleAnim copy];
        copy.beginTime = beginTime - [beginTimes[i] doubleValue];
        [L addAnimation:copy forKey:@"zhh.pulse"];
        [view.layer addSublayer:L];
        [tracked addObject:L];
    }
}

@end
