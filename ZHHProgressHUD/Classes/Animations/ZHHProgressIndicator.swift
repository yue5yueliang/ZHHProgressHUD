//
//  ZHHProgressIndicator.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

/// 进度指示器协议
public protocol ZHHProgressIndicating: ZHHActivityIndicating {
    
    /// 进度值 (0.0 - 1.0)
    var progress: CGFloat { get set }
}

/// 默认进度指示器 - 显示圆形进度条和百分比文本
class DefaultProgressIndicator: ActivityIndicatorLayer, ZHHProgressIndicating {
    
    /// 进度文本标签
    private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 背景轨道图层
    private let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    /// 轨道颜色
    var trackColor: UIColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 1) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    /// 指示器颜色
    override var color: UIColor {
        didSet {
            textLabel.textColor = color
        }
    }
    
    /// 是否隐藏进度文本
    var isProgressTextHidden: Bool {
        get {
            textLabel.isHidden
        }
        set {
            textLabel.isHidden = newValue
        }
    }
    
        
    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)

        // 计算容器尺寸和半径
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = min(containerSize.width, containerSize.height) * 0.5 - lineWidth * 0.5
        
        // 创建圆形路径
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: radius,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
        
        // 设置背景轨道
        trackLayer.frame = layer.frame
        trackLayer.lineWidth = layer.lineWidth
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.path = path.cgPath
        containerView.layer.insertSublayer(trackLayer, below: layer)

        // 添加进度文本标签
        containerView.addSubview(
            textLabel,
            constraints:
                textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        )
        
        textLabel.textColor = color
        updateProgressValue()
    }
    
    /// 从父视图中移除指示器并停止动画
    override func remove() {
        super.remove()
        trackLayer.removeFromSuperlayer()
        textLabel.removeFromSuperview()
    }
    
    
    
    // MARK: - ZHHProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
        layer.strokeEnd = progress
    }
    
    var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}

class HalfCircleProgressIndicator: HalfCircleActivityIndicator, ZHHProgressIndicating {

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override var color: UIColor {
        didSet {
            textLabel.textColor = color
        }
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        containerView.addSubview(
            textLabel,
            constraints:
                textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        )
        textLabel.textColor = color

        updateProgressValue()
    }

    /// 从父视图中移除指示器并停止动画
    override func remove() {
        super.remove()
        textLabel.removeFromSuperview()
    }
    
    
    
    // MARK: - ZHHProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
    }
    
    var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}
