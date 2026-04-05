//
//  ZHHLoadingAnimAsymmetricDots.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimAsymmetricDots : NSObject

/// 在 `view` 内按圆周排布 8 个实心圆并播放组合动画。
+ (void)addToView:(UIView *)view color:(UIColor *)color;

/// 移除本类在该 `view` 上的全部圆点图层。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
