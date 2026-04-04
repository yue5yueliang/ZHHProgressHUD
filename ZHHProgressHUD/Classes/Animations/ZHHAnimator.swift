//
//  ZHHAnimator.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//
        
import UIKit

/// HUD 转场动画协议
public protocol ZHHAnimatorTransitioning {
        
    /// 是否正在显示
    func isAppearing(hud: ZHHProgressHUD) -> Bool

    /// 是否正在隐藏
    func isDisappearing(hud: ZHHProgressHUD) -> Bool

    /// 显示动画
    func show(hud: ZHHProgressHUD)
    
    /// 隐藏动画
    func hide(hud: ZHHProgressHUD)
    
    /// 取消动画
    func cancel(hud: ZHHProgressHUD)
}

public extension ZHHAnimatorTransitioning {
    
    func isAppearing(hud: ZHHProgressHUD) -> Bool {
        hud.layer.animation(forKey: ViewMetrics.showAnimationKey) != nil
    }

    func isDisappearing(hud: ZHHProgressHUD) -> Bool {
        hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) != nil
    }
}


/// 视图度量常量
private struct ViewMetrics {
    /// 显示动画的键值
    static var showAnimationKey: String { "com.yue5yueliang.ZHHProgressHUD.Animator.show" }

    /// 隐藏动画的键值
    static var hideAnimationKey: String { "com.yue5yueliang.ZHHProgressHUD.Animator.hide" }

    /// 动画持续时间
    static var duration: TimeInterval { 0.15 }

    /// 缩放类转场消失时长（长于出现，淡出更顺）
    static var zoomHideDuration: TimeInterval { 0.26 }

    /// 缩放类转场的小端比例（与 Popover 居中一致；默认路径为 ZoomAnimator）
    static var zoomScale: CGFloat { 0.96 }
}



/// 淡入淡出动画器 - 提供简单的透明度变化动画
class FadeAnimator: ZHHAnimatorTransitioning {

    func show(hud: ZHHProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        // 创建透明度动画
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = ViewMetrics.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.isRemovedOnCompletion = true
        hud.layer.add(animation, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: ZHHProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        // 创建透明度动画
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = ViewMetrics.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        // 动画完成后移除视图（finished 为 false 时表示被 removeAnimation/cancel，不得再移除视图）
        animation.completion = { [weak hud] finished in
            guard finished, let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.add(animation, forKey: ViewMetrics.hideAnimationKey)
    }

    func cancel(hud: ZHHProgressHUD) {
        // 移除显示动画
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        // 勿对 layer.animation(forKey:) 返回的对象设 delegate/completion，其为只读会抛 CAAnimationImmutable
        hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        // 重置透明度
        hud.layer.opacity = 1.0
    }
}

/// 缩放动画器 - 提供缩放和透明度组合动画
class ZoomAnimator: ZHHAnimatorTransitioning {
    
    func show(hud: ZHHProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        // 创建透明度动画
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = true

        // 创建缩放动画
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [ViewMetrics.zoomScale, 1.0]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scaleAnimation.isRemovedOnCompletion = true

        hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: ZHHProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        // 创建透明度动画
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = ViewMetrics.zoomHideDuration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        // 动画完成后移除视图（finished 为 false 时表示被 removeAnimation/cancel）
        opacityAnimation.completion = { [weak hud] finished in
            guard finished, let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
            hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        
        // 创建缩放动画
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, ViewMetrics.zoomScale]
        scaleAnimation.duration = ViewMetrics.zoomHideDuration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
         
        hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.hideAnimationKey)
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
    }
    
    func cancel(hud: ZHHProgressHUD) {
        // 移除显示动画
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.layer.opacity = 1.0
        
        // 移除容器视图的动画并重置变换
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}

/// 平移缩放动画器 - 提供平移、缩放和透明度的组合动画
class TranslationZoomAnimator: ZHHAnimatorTransitioning {
    
    /// 平移距离
    let translation: CGPoint
    
    init(translation: CGPoint) {
        self.translation = translation
    }
     
    func show(hud: ZHHProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        // 创建透明度动画
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = true

        // 创建缩放动画
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [ViewMetrics.zoomScale, 1.0]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scaleAnimation.isRemovedOnCompletion = true
        
        // 创建平移动画
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.values = [translation, CGPoint.zero]
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = true
        
        // 创建组合动画
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = ViewMetrics.duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.isRemovedOnCompletion = true
        animationGroup.animations = [scaleAnimation, translationAnimation]

        hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.add(animationGroup, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: ZHHProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.completion = { [weak hud] finished in
            guard finished, let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
            hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, ViewMetrics.zoomScale]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
        
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.values = [CGPoint.zero, translation]
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.fillMode = .forwards
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = ViewMetrics.duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.animations = [scaleAnimation, translationAnimation]

        hud.containerView.layer.add(animationGroup, forKey: ViewMetrics.hideAnimationKey)
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
    }
    
    func cancel(hud: ZHHProgressHUD) {
        // 移除显示动画
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.layer.opacity = 1.0

        // 移除容器视图的动画并重置变换
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}

/// 弹出动画器 - 根据 HUD 位置提供不同的弹出动画效果
class PopoverAnimator: ZHHAnimatorTransitioning {
    
    /// 居中卡片出现时长（略短，偏「弹出」）
    private var centerCardShowDuration: TimeInterval { 0.24 }
    
    /// 顶/底出现：弹簧略带回弹，接近系统 sheet / 横幅质感
    private func springShowTranslationY(from startY: CGFloat) -> CASpringAnimation {
        let spring = CASpringAnimation(keyPath: "transform.translation.y")
        spring.fromValue = startY
        spring.toValue = 0
        spring.mass = 1
        spring.stiffness = 300
        spring.damping = 24
        spring.initialVelocity = 0
        spring.isRemovedOnCompletion = true
        spring.duration = spring.settlingDuration
        return spring
    }
    
    /// 收起：略长于全局 0.15s，曲线前段缓、后段加速离场，避免「戛然而止」
    private var popoverHideDuration: TimeInterval { 0.28 }
    
    /// 与 iOS 默认 ease-in 相近的离场曲线
    private var popoverHideTiming: CAMediaTimingFunction {
        CAMediaTimingFunction(controlPoints: 0.42, 0, 1, 1)
    }
    
    /// 与位移动画等长、`opacity` 恒为 1 的占位，满足 `hud.layer` 上的 show/hide key 检测；`hold` 为 true 时与离场位移同步直到 `removeAnimation`
    private func noopLayerAnimation(duration: CFTimeInterval, hold: Bool = false) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: "opacity")
        a.fromValue = 1.0
        a.toValue = 1.0
        a.duration = duration
        a.isRemovedOnCompletion = !hold
        if hold {
            a.fillMode = .forwards
        }
        return a
    }
    
    func show(hud: ZHHProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        hud.layoutIfNeeded()

        switch hud.location {
            case .top:
                hud.layer.opacity = 1.0
                let ty = springShowTranslationY(from: -hud.containerView.frame.maxY)
                hud.layer.add(noopLayerAnimation(duration: ty.duration), forKey: ViewMetrics.showAnimationKey)
                hud.containerView.layer.add(ty, forKey: ViewMetrics.showAnimationKey)
            case .bottom:
                hud.layer.opacity = 1.0
                let ty = springShowTranslationY(from: hud.frame.height - hud.containerView.frame.minY)
                hud.layer.add(noopLayerAnimation(duration: ty.duration), forKey: ViewMetrics.showAnimationKey)
                hud.containerView.layer.add(ty, forKey: ViewMetrics.showAnimationKey)
            case .center:
                let duration = centerCardShowDuration
                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.fromValue = 0.0
                opacityAnimation.toValue = 1.0
                opacityAnimation.duration = duration
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                opacityAnimation.isRemovedOnCompletion = true
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = ViewMetrics.zoomScale
                scaleAnimation.toValue = 1.0
                scaleAnimation.duration = duration
                scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                scaleAnimation.isRemovedOnCompletion = true
                hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
                hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.showAnimationKey)
        }
    }

    func hide(hud: ZHHProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let hideDuration = popoverHideDuration
        
        switch hud.location {
            case .top:
                hud.layer.opacity = 1.0
                let translationAnimation = CABasicAnimation(keyPath: "transform.translation.y")
                translationAnimation.fromValue = 0
                translationAnimation.toValue = -hud.containerView.frame.maxY
                translationAnimation.duration = hideDuration
                translationAnimation.timingFunction = popoverHideTiming
                translationAnimation.isRemovedOnCompletion = false
                translationAnimation.fillMode = .forwards
                translationAnimation.completion = { [weak hud] finished in
                    guard finished, let hud = hud else {
                        return
                    }
                    hud.removeFromSuperview()
                    hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                    hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                }
                hud.layer.add(noopLayerAnimation(duration: hideDuration, hold: true), forKey: ViewMetrics.hideAnimationKey)
                hud.containerView.layer.add(translationAnimation, forKey: ViewMetrics.hideAnimationKey)
            case .bottom:
                hud.layer.opacity = 1.0
                let translationAnimation = CABasicAnimation(keyPath: "transform.translation.y")
                translationAnimation.fromValue = 0
                translationAnimation.toValue = hud.frame.height - hud.containerView.frame.minY
                translationAnimation.duration = hideDuration
                translationAnimation.timingFunction = popoverHideTiming
                translationAnimation.isRemovedOnCompletion = false
                translationAnimation.fillMode = .forwards
                translationAnimation.completion = { [weak hud] finished in
                    guard finished, let hud = hud else {
                        return
                    }
                    hud.removeFromSuperview()
                    hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                    hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                }
                hud.layer.add(noopLayerAnimation(duration: hideDuration, hold: true), forKey: ViewMetrics.hideAnimationKey)
                hud.containerView.layer.add(translationAnimation, forKey: ViewMetrics.hideAnimationKey)
            case .center:
                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.fromValue = 1.0
                opacityAnimation.toValue = 0.0
                opacityAnimation.duration = hideDuration
                opacityAnimation.timingFunction = popoverHideTiming
                opacityAnimation.isRemovedOnCompletion = false
                opacityAnimation.fillMode = .forwards
                opacityAnimation.completion = { [weak hud] finished in
                    guard finished, let hud = hud else {
                        return
                    }
                    hud.removeFromSuperview()
                    hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                    hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
                }
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = 1.0
                scaleAnimation.toValue = ViewMetrics.zoomScale
                scaleAnimation.duration = hideDuration
                scaleAnimation.timingFunction = popoverHideTiming
                scaleAnimation.isRemovedOnCompletion = false
                scaleAnimation.fillMode = .forwards
                hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
                hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.hideAnimationKey)
        }
    }
    
    func cancel(hud: ZHHProgressHUD) {
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.layer.opacity = 1.0

        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}
