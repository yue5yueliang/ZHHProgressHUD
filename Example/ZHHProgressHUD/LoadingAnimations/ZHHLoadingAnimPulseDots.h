//
//  ZHHLoadingAnimPulseDots.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimPulseDots : NSObject

/// 在 `view` 宽度内排布三点并播放脉冲缩放；会先清理本类旧图层。
+ (void)addToView:(UIView *)view color:(UIColor *)color;

/// 移除本类在该 `view` 上的全部圆点图层。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
