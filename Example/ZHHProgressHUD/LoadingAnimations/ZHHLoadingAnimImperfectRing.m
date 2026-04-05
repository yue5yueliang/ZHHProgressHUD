//
//  ZHHLoadingAnimImperfectRing.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimImperfectRing.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimImperfectRingKey;

@implementation ZHHLoadingAnimImperfectRing

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimImperfectRingKey);
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
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimImperfectRingKey);
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
    layer.strokeStart = 0;
    layer.strokeEnd = 0.82; // 留一小段缺口
    layer.frame = CGRectMake(0, 0, sz.width, sz.height);
    layer.contentsScale = UIScreen.mainScreen.scale;

    NSTimeInterval d = 1.0;
    CABasicAnimation *rot = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rot.byValue = @(M_PI * 2);
    rot.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAAnimationGroup *g = [CAAnimationGroup animation];
    g.animations = @[rot];
    g.duration = d;
    g.repeatCount = HUGE_VALF;
    g.removedOnCompletion = NO;
    g.fillMode = kCAFillModeForwards;
    [layer addAnimation:g forKey:@"zhh.imperfect"];

    [view.layer addSublayer:layer];
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimImperfectRingKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimImperfectRingKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tracked addObject:layer];
}

@end
