//
//  ZHHLoadingAnimGradientRing.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimGradientRing : NSObject

/// 构建渐变遮罩圆环并旋转；会先清理本类旧图层。
+ (void)addToView:(UIView *)view color:(UIColor *)color lineWidth:(CGFloat)lineWidth;

/// 移除本类在该 `view` 上记录的图层（含子 mask 结构一并移除）。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
