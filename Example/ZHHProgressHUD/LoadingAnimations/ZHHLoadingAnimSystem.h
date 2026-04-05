//
//  ZHHLoadingAnimSystem.h
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 在容器上展示系统 `UIActivityIndicatorView`（大号样式），通过关联对象记录子视图以便移除。
@interface ZHHLoadingAnimSystem : NSObject

/// 先移除本类此前加在同一 `view` 上的指示器，再添加新的并开启动画。需保证 `view.bounds` 已有效。
+ (void)addToView:(UIView *)view color:(UIColor *)color;

/// 停止动画并移除本类记录在 `view` 上的子视图/子图层，清空关联数组。
+ (void)stopInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
