//
//  NSLayoutConstraint+Ext.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

/// 约束流式配置，便于链式书写优先级与激活状态
extension NSLayoutConstraint {
    
    /// 设置布局优先级，返回自身以继续链式调用
    @discardableResult
    func priority(_ layoutPriority: UILayoutPriority) -> Self {
        priority = layoutPriority
        return self
    }
    
    /// 设置是否激活，返回自身以继续链式调用
    @discardableResult
    func active(_ isActive: Bool) -> Self {
        self.isActive = isActive
        return self
    }
}
