//
//  ZHHLoadingAnimCircleStroke.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimCircleStroke : NSObject

/// 在 `view` 上添加 `CAShapeLayer` 圆环并播放组合动画；会先清理本类旧图层。
+ (void)addToView:(UIView *)view color:(UIColor *)color lineWidth:(CGFloat)lineWidth;

/// 移除本类记录在该 `view` 上的图层并清空关联。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
