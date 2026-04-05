//
//  ExampleSwiftLoadingAnimations.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit
import ZHHProgressHUD

// MARK: - 活动指示器

/// 活动指示器基类
class BaseActivityIndicator: ZHHActivityIndicating {

    /// 指示器颜色
    var color: UIColor = .white {
        didSet {
            updateColor()
        }
    }

    /// 指示器线条宽度
    var lineWidth: CGFloat = 3.0 {
        didSet {
            updateLineWidth()
        }
    }

    /// 动画持续时间
    var duration: TimeInterval = 1.5

    required init() { }

    /// 通过类名字符串创建对应的指示器实例
    /// - Parameter classString: 类名字符串
    /// - Returns: 对应的指示器实例，如果创建失败则返回 nil
    static func asIndicator(_ classString: String) -> BaseActivityIndicator? {
        let className = NSStringFromClass(BaseActivityIndicator.self)
            .replacingOccurrences(of: "BaseActivityIndicator", with: classString)
        guard let classType = NSClassFromString(className) as? BaseActivityIndicator.Type else {
            return nil
        }
        return classType.init()
    }

    // MARK: - 子类可重写的方法

    /// 更新颜色，子类可重写
    func updateColor() { }

    /// 更新线条宽度，子类可重写
    func updateLineWidth() { }

    // MARK: - ZHHActivityIndicating

    /// 将指示器添加到指定的容器视图并开始动画，子类必须重写
    /// - Parameter containerView: 指示器将要添加到的视图
    public func apply(in containerView: UIView) { }

    /// 从父视图中移除指示器并停止动画，子类必须重写
    public func remove() { }

    deinit {
        remove()
    }
}

/// 系统活动指示器
class SystemActivityIndicator: BaseActivityIndicator {

    /// 系统活动指示器视图
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.style = .large
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.hidesWhenStopped = false
        return indicatorView
    }()

    /// 指示器颜色
    override var color: UIColor {
        didSet {
            activityIndicatorView.color = color
        }
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        // 确保先移除旧的指示器，避免重复添加
        remove()

        activityIndicatorView.color = color
        activityIndicatorView.frame = containerView.bounds
        activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicatorView)
    }

    /// 从父视图中移除指示器并停止动画
    override func remove() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}

/// 基于 Core Animation 的活动指示器基类
class ActivityIndicatorLayer: BaseActivityIndicator {

    /// 指示器图层
    let layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()

    /// 指示器线条宽度
    override var lineWidth: CGFloat {
        didSet {
            layer.lineWidth = lineWidth
        }
    }

    /// 指示器颜色
    override var color: UIColor {
        didSet {
            layer.strokeColor = color.cgColor
        }
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        remove()

        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        layer.frame = CGRect(origin: .zero, size: containerSize)
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layoutPath(in: containerView, containerSize: containerSize)
        loadAnimations()
        containerView.layer.addSublayer(layer)
    }

    /// 从父视图中移除指示器并停止动画
    override func remove() {
        layer.removeFromSuperlayer()
        layer.removeAllAnimations()
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }

    /// 在 `loadAnimations` 之前设置 `layer.path` 等几何，需描边动画的子类应重写
    func layoutPath(in containerView: UIView, containerSize: CGSize) { }

    /// 加载动画 - 子类必须重写此方法来添加具体的动画效果
    func loadAnimations() { }
}

// MARK: - 圆形指示器

/// 圆形活动指示器 - 显示旋转的圆形进度
class CircleActivityIndicator: ActivityIndicatorLayer {

    override func layoutPath(in containerView: UIView, containerSize: CGSize) {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: (min(containerSize.height, containerSize.width) - lineWidth) * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
    }

    override func loadAnimations() {
        // 旋转动画
        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2.0 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        // 描边开始动画
        let animationStart = CABasicAnimation(keyPath: "strokeStart")
        animationStart.duration = duration * 1.2 / 1.7
        animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        animationStart.fromValue = 0.0
        animationStart.toValue = 1.0
        animationStart.beginTime = duration * 0.5 / 1.7

        // 描边结束动画
        let animationStop = CABasicAnimation(keyPath: "strokeEnd")
        animationStop.duration = duration * 0.7 / 1.7
        animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        animationStop.fromValue = 0.0
        animationStop.toValue = 1.0

        // 组合动画
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationRotation, animationStop, animationStart]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        layer.add(groupAnimation, forKey: "animation")
    }
}

/// 不完整圆形活动指示器 - 显示一个缺口圆环的旋转动画
class ImperfectCircleActivityIndicator: ActivityIndicatorLayer {

    required init() {
        super.init()
        duration = 1.0
    }

    override func layoutPath(in containerView: UIView, containerSize: CGSize) {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: (min(containerSize.height, containerSize.width) - lineWidth) * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
        layer.strokeStart = 0
        layer.strokeEnd = 0.82
    }

    override func loadAnimations() {
        // 简单的旋转动画
        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2.0 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationRotation]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        layer.add(groupAnimation, forKey: "animation")
    }
}

/// 半圆形活动指示器
class HalfCircleActivityIndicator: CircleActivityIndicator {

    /// 视图度量常量
    private struct ViewMetrics {
        static let minStrokeValue: Double = 0.02
        static let maxStrokeValue: Double = 0.5
    }

    required init() {
        super.init()
        duration = 1.0
    }

    override func loadAnimations() {
        // 描边开始动画 - 控制圆弧的起始位置
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnimation.values = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.0),
            NSNumber(value: ViewMetrics.maxStrokeValue)
        ]
        strokeStartAnimation.duration = duration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeStartAnimation.isRemovedOnCompletion = false
        strokeStartAnimation.fillMode = .forwards

        // 描边结束动画 - 控制圆弧的结束位置
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.values = [
            NSNumber(value: ViewMetrics.minStrokeValue),
            NSNumber(value: ViewMetrics.maxStrokeValue),
            NSNumber(value: ViewMetrics.maxStrokeValue + ViewMetrics.minStrokeValue)
        ]
        strokeEndAnimation.duration = duration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeEndAnimation.isRemovedOnCompletion = false
        strokeEndAnimation.fillMode = .forwards

        // 旋转动画
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [NSNumber(value: 0.0), NSNumber(value: Double.pi * 1.0)]
        rotationAnimation.duration = duration
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards

        // 组合动画
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.animations = [strokeStartAnimation, strokeEndAnimation, rotationAnimation]
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        layer.add(groupAnimation, forKey: "animation")
    }
}

/// 渐变圆形活动指示器 - 显示带有渐变效果的圆形进度
class GradientCircleActivityIndicator: HalfCircleActivityIndicator {

    /// 渐变颜色的位置
    var colorLocation: CGFloat = 0.7

    /// 左侧渐变图层
    let leftGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return layer
    }()

    /// 右侧渐变图层
    let rightGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return layer
    }()

    /// 遮罩图层
    let maskLayer = CALayer()

    required init() {
        super.init()
        maskLayer.addSublayer(rightGradientLayer)
        maskLayer.addSublayer(leftGradientLayer)
        layer.mask = maskLayer
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)

        // 计算描边起始位置
        let strokeStart = lineWidth * 0.5 / (min(containerSize.height, containerSize.width) + lineWidth)

        // 设置左侧渐变颜色
        leftGradientLayer.colors = [color, color.withAlphaComponent(colorLocation - strokeStart)]
            .map({ $0.cgColor })
        leftGradientLayer.frame = CGRect(
            x: 0, y: 0,
            width: (containerSize.width + lineWidth) * 0.5,
            height: containerSize.height
        )

        // 设置右侧渐变颜色
        rightGradientLayer.colors = [color.withAlphaComponent(0.0), color.withAlphaComponent(colorLocation)]
            .map({ $0.cgColor })
        rightGradientLayer.frame = CGRect(
            x: (containerSize.width + lineWidth) * 0.5,
            y: 0.0,
            width: containerSize.width * 0.5,
            height: containerSize.height
        )

        maskLayer.frame = layer.bounds
        layer.strokeStart = strokeStart
    }

    override func loadAnimations() {
        // 简单的旋转动画
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.byValue = 2.0 * Float.pi
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "transform.rotation")
    }
}

/// 非对称淡入淡出圆形活动指示器
class AsymmetricFadeCircleActivityIndicator: PulseActivityIndicator {

    required init() {
        super.init()
        spacing = 3.0
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        remove()

        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)

        let animationScale = CAKeyframeAnimation(keyPath: "transform.scale")
        animationScale.keyTimes = [0, 0.5, 1]
        animationScale.values = [1, 0.4, 1]
        animationScale.duration = duration

        let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
        animationOpacity.keyTimes = [0, 0.5, 1]
        animationOpacity.values = [1, 0.3, 1]
        animationOpacity.duration = duration

        let animation = CAAnimationGroup()
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.animations = [animationScale, animationOpacity]

        let radius = (containerSize.width - 4 * spacing) / 3.5
        let path = UIBezierPath(
            arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
            radius: radius * 0.5,
            startAngle: 0, endAngle: 2 * .pi,
            clockwise: false
        )

        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.84, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0]
        let radiusX = (containerSize.width - radius) * 0.5

        for index in 0..<8 {
            let angle = CGFloat.pi / 4 * CGFloat(index)
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            layer.backgroundColor = nil
            layer.frame = CGRect(x: radiusX * (cos(angle) + 1), y: radiusX * (sin(angle) + 1), width: radius, height: radius)
            guard let animCopy = animation.copy() as? CAAnimationGroup else {
                continue
            }
            animCopy.beginTime = beginTime - beginTimes[index]
            layer.add(animCopy, forKey: "animation")
            containerView.layer.addSublayer(layer)
            layers.append(layer)
        }
    }
}

// MARK: - 其他指示器

/// 脉冲活动指示器 - 显示3个点的脉冲动画效果
class PulseActivityIndicator: BaseActivityIndicator {

    /// 视图度量常量
    private struct ViewMetrics {
        /// 点的数量
        static var count: Int {
            3
        }
    }

    /// 点之间的间距
    var spacing: CGFloat = 6.0

    /// 存储所有图层的数组
    var layers: [CAShapeLayer] = []

    required init() {
        super.init()
        duration = 1.25
    }

    /// 指示器颜色
    override var color: UIColor {
        didSet {
            layers.forEach({
                $0.fillColor = color.cgColor
            })
        }
    }

    /// 将指示器添加到指定的容器视图并开始动画
    /// - Parameter containerView: 指示器将要添加到的视图
    override func apply(in containerView: UIView) {
        remove()

        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = (containerSize.width - spacing * CGFloat(ViewMetrics.count - 1)) / CGFloat(ViewMetrics.count)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
            radius: radius * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        // 创建缩放动画
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.timingFunctions = [
            CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08),
            CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        ]
        animation.values = [1.0, 0.45, 1.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.24, 0.12]

        for index in 0..<ViewMetrics.count {
            let layer = CAShapeLayer()
            layer.frame = CGRect(
                x: (radius + spacing) * CGFloat(index),
                y: (containerSize.height - radius) * 0.5,
                width: radius,
                height: radius
            )
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            guard let animCopy = animation.copy() as? CAKeyframeAnimation else {
                continue
            }
            animCopy.beginTime = beginTime - beginTimes[index]
            layer.add(animCopy, forKey: "animation")
            containerView.layer.addSublayer(layer)
            layers.append(layer)
        }
    }

    /// 从父视图中移除指示器并停止动画
    override func remove() {
        layers.forEach({
            $0.removeFromSuperlayer()
        })
        layers.removeAll()
    }
}

// MARK: - 示例：按 OC 侧 kind 映射（与库内 ActivityIndicatorType 命名一致）

enum ExampleSwiftLoadingAnimations {}

extension ExampleSwiftLoadingAnimations {
    /// 与库内 `ZHHProgressHUD.ActivityIndicatorType` 各 raw 对应的 `*ActivityIndicator` 一致。
    static func makeIndicator(kind: ExampleOCAnimationKind) -> BaseActivityIndicator {
        switch kind {
        case .system:
            return SystemActivityIndicator()
        case .circle:
            return CircleActivityIndicator()
        case .imperfect:
            return ImperfectCircleActivityIndicator()
        case .half:
            return HalfCircleActivityIndicator()
        case .gradient:
            return GradientCircleActivityIndicator()
        case .pulse:
            return PulseActivityIndicator()
        case .asymmetric:
            return AsymmetricFadeCircleActivityIndicator()
        @unknown default:
            return SystemActivityIndicator()
        }
    }
}

// MARK: - 预览页

final class ExampleSwiftAnimationPreviewViewController: UIViewController {

    private let kind: ExampleOCAnimationKind
    private let host = UIView()
    private var didStart = false
    private var activityIndicator: BaseActivityIndicator?
    private let lineWidth: CGFloat = 3

    init(kind: ExampleOCAnimationKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.11, alpha: 1)
        title = ExampleOCAnimationKindTitle(kind) as String
        host.backgroundColor = .clear
        view.addSubview(host)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let side: CGFloat = 88
        host.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        host.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        guard view.bounds.width > 1, !didStart else { return }
        didStart = true
        let indicator = ExampleSwiftLoadingAnimations.makeIndicator(kind: kind)
        indicator.color = .white
        indicator.lineWidth = lineWidth
        indicator.apply(in: host)
        activityIndicator = indicator
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            activityIndicator?.remove()
            activityIndicator = nil
        }
    }
}
