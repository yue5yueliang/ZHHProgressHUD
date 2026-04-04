//
//  UIView+Layout.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 顶部安全区域锚点
    var safeTopAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.topAnchor
    }
    
    /// 底部安全区域锚点
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.bottomAnchor
    }
    
    /// 添加子视图并激活约束
    func addSubview(_ view: UIView, constraints: NSLayoutConstraint...) {
        if view.translatesAutoresizingMaskIntoConstraints {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(view)
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 添加子视图并使其填满父视图
    func addSubviewLayoutEqualToEdges(_ view: UIView) {
        addSubview(
            view,
            constraints:
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
        )
    }
}
