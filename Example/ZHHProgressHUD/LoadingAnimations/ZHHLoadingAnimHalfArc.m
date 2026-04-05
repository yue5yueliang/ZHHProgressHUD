//
//  ZHHLoadingAnimHalfArc.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimHalfArc.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimHalfArcKey;

@implementation ZHHLoadingAnimHalfArc

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimHalfArcKey);
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

+ (void)addToView:(UIView *)view color:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimHalfArcKey);
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
    CGFloat circleR = (MIN(sz.height, sz.width) - lineWidth) * 0.5;
    CGPoint circleC = CGPointMake(sz.width * 0.5, sz.height * 0.5);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circleC radius:circleR startAngle:(CGFloat)(-M_PI_2) endAngle:(CGFloat)(M_PI * 1.5) clockwise:YES];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = NULL;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.path = circlePath.CGPath;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = lineWidth;
    layer.frame = CGRectMake(0, 0, sz.width, sz.height);
    layer.contentsScale = UIScreen.mainScreen.scale;

    NSTimeInterval d = 1.0;
    const double minS = 0.02;
    const double maxS = 0.5;

    // 弧段起点沿圆周「追赶」
    CAKeyframeAnimation *strokeStart = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    strokeStart.values = @[@0, @0, @(maxS)];
    strokeStart.duration = d;
    strokeStart.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeStart.removedOnCompletion = NO;
    strokeStart.fillMode = kCAFillModeForwards;

    // 弧段终点与起点配合，保持可见弧长约半圈附近变化
    CAKeyframeAnimation *strokeEnd = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEnd.values = @[@(minS), @(maxS), @(maxS + minS)];
    strokeEnd.duration = d;
    strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeEnd.removedOnCompletion = NO;
    strokeEnd.fillMode = kCAFillModeForwards;

    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.values = @[@0, @(M_PI)];
    rotation.duration = d;
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotation.removedOnCompletion = NO;
    rotation.fillMode = kCAFillModeForwards;

    CAAnimationGroup *g = [CAAnimationGroup animation];
    g.duration = d;
    g.animations = @[strokeStart, strokeEnd, rotation];
    g.repeatCount = HUGE_VALF;
    g.removedOnCompletion = NO;
    g.fillMode = kCAFillModeForwards;
    [layer addAnimation:g forKey:@"zhh.half"];

    [view.layer addSublayer:layer];
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimHalfArcKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimHalfArcKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tracked addObject:layer];
}

@end
