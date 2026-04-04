//
//  StateIndicator.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

/// 状态指示器 - 显示成功或失败状态的动画
class StateIndicator: CircleActivityIndicator {
    
    /// 视图度量常量
    private struct ViewMetrics {
        /// 动画持续时间
        static let duration: TimeInterval = 0.34
        /// 失败状态线条的百分比位置
        static let failPercentage: CGFloat = 0.8
        /// 与描边同步的轻微缩放起点，略小于 1 以形成「落定」感
        static let scaleFrom: CGFloat = 0.86
    }
    
    typealias State = ZHHProgressHUD.State
    
    /// 当前状态
    let state: State
  
    init(state: State) {
        self.state = state
        super.init()
        duration = ViewMetrics.duration
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let path = UIBezierPath()
        
        // 根据状态创建不同的路径
        switch state {
            case .success:
                // 成功状态：绘制对勾
                path.move(to: CGPoint(x: lineWidth * 0.5, y: containerSize.height * 0.55))
                path.addLine(to: CGPoint(x: containerSize.width * 0.39, y: containerSize.height * 0.9 - lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width - lineWidth * 0.5, y: containerSize.height * 0.1 + lineWidth * 0.5))
            
            case .failure:
                // 失败状态：绘制叉号
                path.move(to: CGPoint(x: containerSize.width * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5, y: containerSize.height * 0.2 + lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width * ViewMetrics.failPercentage - lineWidth * 0.5, y: containerSize.height * ViewMetrics.failPercentage - lineWidth * 0.5))
                path.move(to: CGPoint(x: containerSize.width * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5, y: containerSize.height * ViewMetrics.failPercentage - lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width * ViewMetrics.failPercentage - lineWidth * 0.5, y: containerSize.height * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5))
        }
        
        // 先设置 path 再挂 stroke 动画，避免 path 为空时动画无效
        layer.frame = CGRect(origin: .zero, size: containerSize)
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.path = path.cgPath
        loadAnimations()
        containerView.layer.addSublayer(layer)
    }
    
    override func loadAnimations() {
        // 成功 / 失败统一：整段路径 strokeEnd 展开 + 轻微缩放；模型层保持终态，动画结束可安全移除
        layer.strokeEnd = 1
        layer.opacity = 1
        layer.transform = CATransform3DIdentity

        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.fromValue = 0
        stroke.toValue = 1

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = ViewMetrics.scaleFrom
        scale.toValue = 1

        let group = CAAnimationGroup()
        group.animations = [stroke, scale]
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = true

        layer.add(group, forKey: "stateReveal")
    }
}
