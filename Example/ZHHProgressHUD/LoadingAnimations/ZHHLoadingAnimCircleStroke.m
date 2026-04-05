//
//  ZHHLoadingAnimCircleStroke.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ZHHLoadingAnimCircleStroke.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kZHHLoadingAnimCircleStrokeKey;

@implementation ZHHLoadingAnimCircleStroke

+ (void)stopInView:(UIView *)view {
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimCircleStrokeKey);
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
    NSMutableArray *a = objc_getAssociatedObject(view, &kZHHLoadingAnimCircleStrokeKey);
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
    // 以短边为准算半径，留出 lineWidth 的描边占用
    CGFloat circleR = (MIN(sz.height, sz.width) - lineWidth) * 0.5;
    CGPoint circleC = CGPointMake(sz.width * 0.5, sz.height * 0.5);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circleC radius:circleR startAngle:(CGFloat)(-M_PI_2) endAngle:(CGFloat)(M_PI * 1.5) clockwise:YES];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = NULL;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeStart = 0;
    layer.strokeEnd = 1;
    layer.contentsScale = UIScreen.mainScreen.scale;
    layer.path = circlePath.CGPath;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = lineWidth;
    layer.frame = CGRectMake(0, 0, sz.width, sz.height);

    NSTimeInterval d = 1.5;
    // 匀速整圈旋转
    CABasicAnimation *rot = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rot.byValue = @(M_PI * 2);
    rot.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    // 描边起点/终点错相变化，形成「弧线爬行」观感
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStart.duration = d * 1.2 / 1.7;
    strokeStart.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.0f :0.2f :1.0f];
    strokeStart.fromValue = @0;
    strokeStart.toValue = @1;
    strokeStart.beginTime = d * 0.5 / 1.7;

    CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEnd.duration = d * 0.7 / 1.7;
    strokeEnd.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.0f :0.2f :1.0f];
    strokeEnd.fromValue = @0;
    strokeEnd.toValue = @1;

    CAAnimationGroup *g = [CAAnimationGroup animation];
    g.animations = @[rot, strokeEnd, strokeStart];
    g.duration = d;
    g.repeatCount = HUGE_VALF;
    g.removedOnCompletion = NO;
    g.fillMode = kCAFillModeForwards;
    [layer addAnimation:g forKey:@"zhh.circle"];

    [view.layer addSublayer:layer];
    NSMutableArray *tracked = objc_getAssociatedObject(view, &kZHHLoadingAnimCircleStrokeKey);
    if (!tracked) {
        tracked = [NSMutableArray array];
        objc_setAssociatedObject(view, &kZHHLoadingAnimCircleStrokeKey, tracked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [tracked addObject:layer];
}

@end
