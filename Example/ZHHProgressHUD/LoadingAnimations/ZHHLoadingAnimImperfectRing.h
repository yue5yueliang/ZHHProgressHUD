//
//  ZHHLoadingAnimImperfectRing.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHLoadingAnimImperfectRing : NSObject

/// 添加缺口圆环图层并循环旋转；会先清理本类旧图层。
+ (void)addToView:(UIView *)view color:(UIColor *)color lineWidth:(CGFloat)lineWidth;

/// 停止并移除本类在该 `view` 上记录的图层。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
