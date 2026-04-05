//
//  ZHHLoadingAnimGradientRing.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimGradientRing.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimGradientRingKey;

@implementation ZHHLoadingAnimGradientRing

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimGradientRingKey);
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
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimGradientRingKey);
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
    CGFloat colorLocation = 0.7;
    // 略抬 stroke 起点，避免线宽在接缝处挤成一团
    CGFloat strokeStart = lineWidth * 0.5 / (MIN(sz.height, sz.width) + lineWidth);

    CGFloat circleR = (MIN(sz.height, sz.width) - lineWidth) * 0.5;
    CGPoint circleC = CGPointMake(sz.width * 0.5, sz.height * 0.5);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circleC radius:circleR startAngle:(CGFloat)(-M_PI_2) endAngle:(CGFloat)(M_PI * 1.5) clockwise:YES];

    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.fillColor = NULL;
    ring.lineCap = kCALineCapRound;
    ring.lineJoin = kCALineJoinRound;
    ring.path = circlePath.CGPath;
    ring.strokeColor = color.CGColor;
    ring.lineWidth = lineWidth;
    ring.frame = CGRectMake(0, 0, sz.width, sz.height);
    ring.contentsScale = UIScreen.mainScreen.scale;
    ring.strokeStart = strokeStart;

    // 左半：实色到半透明；右半：透明到中等透明度，叠在 ring.mask 上形成沿环渐变
    CAGradientLayer *leftG = [CAGradientLayer layer];
    leftG.startPoint = CGPointMake(0, 0);
    leftG.endPoint = CGPointMake(0, 1);
    CGFloat alphaMid = MAX(0.0, MIN(1.0, colorLocation - strokeStart));
    leftG.colors = @[(id)color.CGColor, (id)[color colorWithAlphaComponent:alphaMid].CGColor];
    leftG.frame = CGRectMake(0, 0, (sz.width + lineWidth) * 0.5, sz.height);

    CAGradientLayer *rightG = [CAGradientLayer layer];
    rightG.startPoint = CGPointMake(0, 0);
    rightG.endPoint = CGPointMake(0, 1);
    rightG.colors = @[(id)[color colorWithAlphaComponent:0].CGColor, (id)[color colorWithAlphaComponent:colorLocation].CGColor];
    rightG.frame = CGRectMake((sz.width + lineWidth) * 0.5, 0, sz.width * 0.5, sz.height);

    CALayer *mask = [CALayer layer];
    [mask addSublayer:rightG];
    [mask addSublayer:leftG];
    mask.frame = ring.bounds;
    ring.mask = mask;

    NSTimeInterval d = 1.0;
    CABasicAnimation *rot = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rot.byValue = @(M_PI * 2);
    rot.duration = d;
    rot.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rot.repeatCount = HUGE_VALF;
    rot.removedOnCompletion = NO;
    rot.fillMode = kCAFillModeForwards;
    [ring addAnimation:rot forKey:@"zhh.grad"];

    [view.layer addSublayer:ring];
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimGradientRingKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimGradientRingKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tracked addObject:ring];
}

@end
