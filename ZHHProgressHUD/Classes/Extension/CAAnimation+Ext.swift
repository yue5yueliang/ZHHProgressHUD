//
//  CAAnimation+Ext.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//
import QuartzCore

/// CAAnimationDelegate 内部实现
private class CAAnimationDelegator: NSObject, CAAnimationDelegate {
    
    var completion: ((Bool) -> Void)?
    /// 动画结束前自持有，避免 delegate 弱引用导致提前释放
    fileprivate var retention: CAAnimationDelegator?
    
    func animationDidStop(_ theAnimation: CAAnimation, finished: Bool) {
        retention = nil
        let callback = completion
        completion = nil
        callback?(finished)
    }
}

public extension CAAnimation {
    
    /// 动画结束时的回调
    var completion: ((Bool) -> Void)? {
        set {
            if newValue == nil {
                if let delegator = delegate as? CAAnimationDelegator {
                    delegator.retention = nil
                    delegator.completion = nil
                }
                // 注意：勿对 layer.animation(forKey:) 返回的只读动画调用本 setter，改 delegate 会抛 CAAnimationImmutable
                delegate = nil
                return
            }
            if let delegator = delegate as? CAAnimationDelegator {
                delegator.completion = newValue
                delegator.retention = delegator
            } else {
                let delegator = CAAnimationDelegator()
                delegator.completion = newValue
                delegator.retention = delegator
                delegate = delegator
            }
        }
        get {
            if let delegator = delegate as? CAAnimationDelegator {
                return delegator.completion
            }
            return nil
        }
    }
}
