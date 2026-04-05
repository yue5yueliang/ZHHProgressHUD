//
//  ExampleOCAnimationPreviewViewController.m
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "ExampleOCAnimationPreviewViewController.h"
#import "ZHHLoadingAnimImports.h"

NSString *ExampleOCAnimationKindTitle(ExampleOCAnimationKind kind) {
    switch (kind) {
        case ExampleOCAnimationKindSystem:
            return @"系统菊花";
        case ExampleOCAnimationKindCircle:
            return @"整圆描边（旋转 + stroke）";
        case ExampleOCAnimationKindImperfect:
            return @"缺口圆环旋转";
        case ExampleOCAnimationKindHalf:
            return @"半圆弧周期";
        case ExampleOCAnimationKindGradient:
            return @"渐变圆环旋转";
        case ExampleOCAnimationKindPulse:
            return @"三点脉冲";
        case ExampleOCAnimationKindAsymmetric:
            return @"八点缩放淡入淡出";
    }
}

@interface ExampleOCAnimationPreviewViewController ()
@property (nonatomic, assign) ExampleOCAnimationKind kind;
@property (nonatomic, strong) UIView *host;
@property (nonatomic, assign) BOOL didStartAnim;
@end

@implementation ExampleOCAnimationPreviewViewController

- (instancetype)initWithKind:(ExampleOCAnimationKind)kind {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _kind = kind;
        _host = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.11f alpha:1.0f];
    self.title = ExampleOCAnimationKindTitle(self.kind);
    self.host.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.host];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat side = 88.0;
    self.host.bounds = CGRectMake(0, 0, side, side);
    self.host.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    if (CGRectGetWidth(self.view.bounds) <= 1.0 || self.didStartAnim) {
        return;
    }
    self.didStartAnim = YES;
    UIColor *color = [UIColor whiteColor];
    CGFloat lineWidth = 3.0;
    switch (self.kind) {
        case ExampleOCAnimationKindSystem:
            [ZHHLoadingAnimSystem addToView:self.host color:color];
            break;
        case ExampleOCAnimationKindCircle:
            [ZHHLoadingAnimCircleStroke addToView:self.host color:color lineWidth:lineWidth];
            break;
        case ExampleOCAnimationKindImperfect:
            [ZHHLoadingAnimImperfectRing addToView:self.host color:color lineWidth:lineWidth];
            break;
        case ExampleOCAnimationKindHalf:
            [ZHHLoadingAnimHalfArc addToView:self.host color:color lineWidth:lineWidth];
            break;
        case ExampleOCAnimationKindGradient:
            [ZHHLoadingAnimGradientRing addToView:self.host color:color lineWidth:lineWidth];
            break;
        case ExampleOCAnimationKindPulse:
            [ZHHLoadingAnimPulseDots addToView:self.host color:color];
            break;
        case ExampleOCAnimationKindAsymmetric:
            [ZHHLoadingAnimAsymmetricDots addToView:self.host color:color];
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        [ZHHLoadingAnimSystem stopInView:self.host];
        [ZHHLoadingAnimCircleStroke stopInView:self.host];
        [ZHHLoadingAnimImperfectRing stopInView:self.host];
        [ZHHLoadingAnimHalfArc stopInView:self.host];
        [ZHHLoadingAnimGradientRing stopInView:self.host];
        [ZHHLoadingAnimPulseDots stopInView:self.host];
        [ZHHLoadingAnimAsymmetricDots stopInView:self.host];
    }
}

@end
