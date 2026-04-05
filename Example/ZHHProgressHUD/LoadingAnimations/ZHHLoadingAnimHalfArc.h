//
//  ZHHLoadingAnimHalfArc.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimHalfArc : NSObject

/// 添加整圆路径图层，由 stroke 区间 + 旋转关键帧表现「半弧扫动」。
+ (void)addToView:(UIView *)view color:(UIColor *)color lineWidth:(CGFloat)lineWidth;

/// 移除本类在该 `view` 上的图层。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
