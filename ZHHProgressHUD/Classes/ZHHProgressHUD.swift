//
//  ZHHProgressHUD.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

/// 简单的 HUD 窗口，包含进度指示器和可选文本标签
open class ZHHProgressHUD: UIView {
    
    /// 展示 HUD 时的转场样式
    public enum TransitionStyle {
        
        /// 缩放+淡入淡出
        case `default`
        
        /// 淡入淡出
        case fade
        
        /// 平移+缩放
        case translationZoom(translation: CGPoint)

        /// 无动画
        case none
        
        /// 自定义动画
        case custom(ZHHAnimatorTransitioning)
    }
      
    /// 布局轴类型
    public typealias Axis = NSLayoutConstraint.Axis
    
    /// HUD 配置
    public var configuration = ZHHProgressHUD.configuration {
        didSet {
           configure()
        }
    }
    
    private let identifier = "com.yue5yueliang.ZHHProgressHUD"

    /// 创建 HUD
    /// - Parameter configuration: 配置，默认使用 ZHHProgressHUD.configuration
    public init(_ configuration: Configuration = ZHHProgressHUD.configuration) {
        self.configuration = configuration
        super.init(frame: UIScreen.main.bounds)
        
        initView()
        setupSubviews()
        configure()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - 便捷配置
    
    /// 应用配置到视图
    private func configure() {
        isUserInteractionEnabled = !configuration.isUserInteractionEnabled
        backgroundColor = configuration.dimmingColor
        
        containerView.effect = configuration.backgroundEffect
        containerView.backgroundColor = configuration.backgroundColor
        containerView.layer.cornerRadius = configuration.cornerRadius
        containerView.layer.masksToBounds = configuration.cornerRadius > 0
        
        contentStackView.layoutMargins = configuration.contentInsets
        contentStackView.spacing = configuration.spacing
        
        if let activityIndicator = activityIndicator as? BaseActivityIndicator {
            activityIndicator.color = configuration.indicatorColor
            activityIndicator.lineWidth = axis == .vertical ? configuration.verticalLineWidth : configuration.horizontalLineWidth
        }
        
        // 保持 messageLabel 懒加载
        if let messageLabel = contentStackView.arrangedSubviews.compactMap({ $0 as? UILabel }).first {
            messageLabel.font = configuration.messageFont
            messageLabel.textColor = configuration.messageColor
            messageLabel.textAlignment = configuration.messageAlignment
        }
        
        updateAligningIfNeeded()
        fixContentInsetIfNeeded()
    }
    
    /// 带动画更新内容
    open func updateWithAnimation(_ animations: @escaping (ZHHProgressHUD) -> Void) {
        UIView.animate(withDuration: 0.2) {
            animations(self)
            self.layoutIfNeeded()
        }
    }
    
    
     
    // MARK: - 视图
    
    /// 容器视图（毛玻璃效果）
    let containerView = makeContainerView()
    
    /// 内容堆栈视图
    private let contentStackView = makeContentStackView()
    
    /// 消息标签
    private lazy var messageLabel = makeMessageLabel()

    /// 指示器容器（图片或活动指示器）
    private lazy var indicatorContainerView = makeIconView()

    /// 指示器尺寸约束
    private var indicatorConstraints: [NSLayoutConstraint] = []

    /// 初始化视图基础属性
    private func initView() {
        accessibilityIdentifier = identifier
        isAccessibilityElement = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    /// 内容堆栈尾部约束（用于左对齐时禁用）
    private var contentStackViewFixedTrailingConstraint: NSLayoutConstraint?
    
    /// 设置子视图布局
    private func setupSubviews() {
        containerView.contentView.addSubview(
            contentStackView,
            constraints:
                contentStackView.leadingAnchor.constraint(equalTo: containerView.contentView.leadingAnchor),
                contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.contentView.trailingAnchor).priority(.defaultLow),
                contentStackView.topAnchor.constraint(equalTo: containerView.contentView.topAnchor),
                contentStackView.bottomAnchor.constraint(equalTo: containerView.contentView.bottomAnchor)
        )
        contentStackViewFixedTrailingConstraint = contentStackView.trailingAnchor
            .constraint(equalTo: containerView.contentView.trailingAnchor)
            .priority(.defaultHigh)
            .active(true)
        
        addSubview(containerView)
        updateContainerViewConstraints()
        updateAligningIfNeeded()
    }
    
    /// 更新指示器容器尺寸约束
    private func updateIndicatorContainerViewConstraints() {
        indicatorContainerView.removeConstraints(indicatorConstraints)
        indicatorConstraints = [
            indicatorContainerView.widthAnchor.constraint(equalToConstant: axis == .vertical ? configuration.verticalIndicatorSize.width : configuration.horizontalIndicatorSize.width),
            indicatorContainerView.heightAnchor.constraint(equalToConstant: axis == .vertical ? configuration.verticalIndicatorSize.height : configuration.horizontalIndicatorSize.height)
        ]
        indicatorContainerView.addConstraints(indicatorConstraints)
        indicatorContainerView.setNeedsLayout()
    }
    
    /// 按需更新内容对齐方式
    private func updateAligningIfNeeded() {
        contentStackViewFixedTrailingConstraint?.isActive = !(configuration.messageAlignment == .left && axis == .horizontal)
        
        if window != nil {
            containerView.contentView.layoutIfNeeded()
        }
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        message = nil
        activityIndicator = nil
        icon = nil
        animator = nil
    }
    
    /// 按需修正内容边距和圆角（紧凑模式）
    private func fixContentInsetIfNeeded() {
        let views = contentStackView.arrangedSubviews.compactMap({ $0.isHidden ? nil : $0 })
        let isCompact = (views.count == 1 && views[0] is UILabel) || axis == .horizontal
         
        contentStackView.layoutMargins = isCompact ? configuration.compactContentInsets : configuration.contentInsets
        containerView.layer.cornerRadius = isCompact ? configuration.compactCornerRadius : configuration.cornerRadius
        containerView.layer.masksToBounds = containerView.layer.cornerRadius > 0
    }
    
    
    
    // MARK: - 位置
    
    /// HUD 显示位置；顶、底相对安全区（`safeTopAnchor` / `safeBottomAnchor`），`offset` 为再向内缩进的附加间距
    open var location: Location = .default {
        didSet {
            guard oldValue != location else {
                return
            }
            updateContainerViewConstraints()
        }
    }
    
    /// 容器位置约束
    private var locationConstraints: [NSLayoutConstraint] = []

    /// 更新容器视图的位置和尺寸约束
    private func updateContainerViewConstraints() {
        if !locationConstraints.isEmpty {
            NSLayoutConstraint.deactivate(locationConstraints)
        }
        locationConstraints = [
            containerView.widthAnchor
                .constraint(greaterThanOrEqualToConstant: configuration.minimumSize.width)
                .priority(.defaultLow),
            containerView.widthAnchor
                .constraint(lessThanOrEqualTo: widthAnchor, multiplier: configuration.maxWidthPercentage)
                .priority(.defaultHigh),
            containerView.heightAnchor
                .constraint(greaterThanOrEqualToConstant: configuration.minimumSize.height)
                .priority(.defaultLow),
            containerView.heightAnchor
                .constraint(lessThanOrEqualTo: heightAnchor, multiplier: configuration.maxHeightPercentage)
                .priority(.defaultHigh),
            containerView.centerXAnchor
                .constraint(equalTo: centerXAnchor)
        ]
        
        switch location {
            case .top(offset: let offset):
                locationConstraints.append(
                    containerView.topAnchor
                        .constraint(equalTo: safeTopAnchor, constant: offset)
                )
            case .center(offset: let offset):
                locationConstraints.append(
                    containerView.centerYAnchor
                        .constraint(equalTo: centerYAnchor, constant: offset)
                )
            case .bottom(offset: let offset):
                locationConstraints.append(
                    containerView.bottomAnchor
                        .constraint(equalTo: safeBottomAnchor, constant: -offset)
                )
        }
        NSLayoutConstraint.activate(locationConstraints)
         
        if window != nil,
           let superview = superview,
            superview.frame.width * superview.frame.height != .zero {
            layoutIfNeeded()
        }
    }
    
     
    
    // MARK: - 属性
    
    /// 内容布局轴方向
    open var axis: Axis {
        get {
            contentStackView.axis
        }
        set {
            guard contentStackView.axis != newValue else {
                return
            }
            contentStackView.axis = newValue
            updateAligningIfNeeded()
        }
    }

    /// 消息文本
    open var message: String? {
        get {
            messageLabel.text
        }
        set {
            // 保持 messageLabel 懒加载
            if !contentStackView.arrangedSubviews.contains(messageLabel) {
                contentStackView.addArrangedSubview(messageLabel)
                messageLabel.font = configuration.messageFont
                messageLabel.textColor = configuration.messageColor
                messageLabel.textAlignment = configuration.messageAlignment
            }

            let isHidden = newValue == nil
            if messageLabel.isHidden != isHidden {
                messageLabel.isHidden = isHidden
            }
            messageLabel.text = newValue
            
            fixContentInsetIfNeeded()
            hideIfNeeded()
        }
    }
    
    /// 富文本消息
    open var attributedMessage: NSAttributedString? {
        get {
            messageLabel.attributedText
        }
        set {
            // 保持 messageLabel 懒加载
            if !contentStackView.arrangedSubviews.contains(messageLabel) {
                contentStackView.addArrangedSubview(messageLabel)
                messageLabel.font = configuration.messageFont
                messageLabel.textColor = configuration.messageColor
                messageLabel.textAlignment = configuration.messageAlignment
            }
            
            let isHidden = newValue == nil
            if messageLabel.isHidden != isHidden {
                messageLabel.isHidden = isHidden
            }
            messageLabel.attributedText = newValue
            
            fixContentInsetIfNeeded()
            hideIfNeeded()
        }
    }
    
    /// 显示的图片
    open var icon: UIImage? {
        willSet {
            let isHidden = newValue == nil && activityIndicator == nil
            if indicatorContainerView.isHidden != isHidden {
                indicatorContainerView.isHidden = isHidden
            }
        }
        didSet {
            if !contentStackView.arrangedSubviews.contains(indicatorContainerView) {
                contentStackView.insertArrangedSubview(indicatorContainerView, at: 0)
            }
            indicatorContainerView.image = icon
            // 与活动指示器共用容器尺寸，必须保留约束；移除约束会导致大图按 intrinsic 撑满
            if icon != nil {
                updateIndicatorContainerViewConstraints()
            }

            fixContentInsetIfNeeded()
            hideIfNeeded()
        }
    }
    
    /// 活动指示器
    open var activityIndicator: ZHHActivityIndicating? {
        willSet {
            activityIndicator?.remove()
            
            let isHidden = newValue == nil && icon == nil
            if indicatorContainerView.isHidden != isHidden {
                indicatorContainerView.isHidden = isHidden
            }
        }
        didSet {
            if !contentStackView.arrangedSubviews.contains(indicatorContainerView) {
                contentStackView.insertArrangedSubview(indicatorContainerView, at: 0)
            }
            if let activityIndicator = activityIndicator {
                updateIndicatorContainerViewConstraints()
                if let activityIndicator = activityIndicator as? BaseActivityIndicator {
                    activityIndicator.color = configuration.indicatorColor
                    activityIndicator.lineWidth = axis == .vertical ? configuration.verticalLineWidth : configuration.horizontalLineWidth
                }
                activityIndicator.apply(in: indicatorContainerView)
            }
            
            fixContentInsetIfNeeded()
            hideIfNeeded()
        }
    }
    
    /// 当前进度值 [0.0, 1.0]
    open var progress: CGFloat = .zero {
        didSet {
            guard let progressIndicator = activityIndicator as? ZHHProgressIndicating else {
                return
            }
            progressIndicator.progress = progress
        }
    }
    
    
    
    // MARK: - 展示
    
    /// 是否自动隐藏，默认 true
    open var autoHide: Bool = true
    
    /// 转场动画器
    private var animator: ZHHAnimatorTransitioning?

    /// 在指定视图中展示 HUD
    ///
    /// - Parameters:
    ///   - windowView: 容器视图
    ///   - transitionStyle: 转场样式
    open func show(in windowView: UIView, transitionStyle: TransitionStyle = .default) {
        guard !windowView.subviews.contains(self) else {
            hideIfNeeded()
            return
        }
        frame = windowView.bounds
        windowView.addSubview(self)
        hideIfNeeded()
        
        guard animator == nil else {
            return
        }
        animator = {
            switch transitionStyle {
                case .default:
                    if axis == .horizontal {
                        switch location {
                            case .top, .bottom:
                                return PopoverAnimator()
                            case .center:
                                break
                        }
                    }
                    return ZoomAnimator()
                case .fade:
                     return FadeAnimator()
                case .translationZoom(let translation):
                    return TranslationZoomAnimator(translation: translation)
            case .custom(let animator):
                    return animator
                case .none:
                     return nil
            }
        }()
        if let animator = animator {
            animator.show(hud: self)
        }
    }
    
    /// 在主窗口展示 HUD
    /// - Parameter transitionStyle: 转场样式
    open func show(transitionStyle: TransitionStyle = .default) {
        guard let window = UIApplication.shared.currentWindow else {
            return
        }
        show(in: window, transitionStyle: transitionStyle)
    }
     
    /// 立即隐藏 HUD
    @objc
    open func hide() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(hide),
            object: self
        )
        if let animator = animator {
            animator.hide(hud: self)
        } else {
            removeFromSuperview()
        }
    }
    
    /// 延迟隐藏 HUD
    /// - Parameter delay: 延迟时间，默认 0.2 秒
    open func hideAfterDelay(_ delay: TimeInterval = 0.2) {
        if delay <= 0 {
            hide()
        } else {
            cancelHidePerformRequest()
            
            perform(#selector(hide), with: self, afterDelay: delay, inModes: [.common])
        }
    }
    
    /// 按需隐藏
    private func hideIfNeeded() {
        if activityIndicator != nil && !(activityIndicator is StateIndicator) {
            cancelHidePerformRequest()
            return
        }
        if superview != nil && autoHide {
            hideAfterDelay(configuration.delayTime)
            return
        }
    }
    
    /// 取消延迟隐藏
    private func cancelHidePerformRequest() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(hide),
            object: self
        )
        
        animator?.cancel(hud: self)
    }
}



// MARK: - 配置

public extension ZHHProgressHUD {
    
    /// HUD 配置
    struct Configuration {
        
        public init() { }
        
        // MARK: - 交互与遮罩
        
        /// 遮罩颜色
        public var dimmingColor: UIColor?
                
        /// 自动隐藏延迟时间，默认 2.5 秒
        public var delayTime: TimeInterval = 2.5
        
        /// 是否禁用用户交互，默认 true
        public var isUserInteractionEnabled: Bool = true
        
        // MARK: - 容器外观
        
        /// 容器背景模糊效果
        public var backgroundEffect: UIVisualEffect? = UIBlurEffect(style: .dark)

        /// 容器背景色
        public var backgroundColor: UIColor = #colorLiteral(red: 0.2823529412, green: 0.2941176471, blue: 0.3333333333, alpha: 1)
        
        /// 圆角半径，默认 14
        public var cornerRadius: CGFloat = 14.0
        
        /// 紧凑模式圆角，默认 8
        public var compactCornerRadius: CGFloat = 8.0
        
        // MARK: - 内容边距与间距
        
        /// 内容间距，默认 12
        public var spacing: CGFloat = 12.0

        /// 内容边距
        public var contentInsets = UIEdgeInsets(top: 20.0, left: 24.0, bottom: 20.0, right: 24.0)
        
        /// 紧凑模式内容边距
        public var compactContentInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
        
        // MARK: - 尺寸限制
                
        /// 最小尺寸
        public var minimumSize: CGSize = .zero
      
        /// 最大宽度占父视图比例，默认 0.8
        public var maxWidthPercentage: CGFloat = 0.8 {
            didSet { maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0) }
        }
        
        /// 最大高度占父视图比例，默认 0.8
        public var maxHeightPercentage: CGFloat = 0.8 {
            didSet { maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0) }
        }
        
        // MARK: - 指示器

        /// 指示器颜色
        public var indicatorColor: UIColor = .white
        
        /// `axis == .vertical` 时指示器/图标占位尺寸
        public var verticalIndicatorSize: CGSize = CGSize(width: 35.0, height: 35.0)
        
        /// `axis == .horizontal` 时指示器/图标占位尺寸
        public var horizontalIndicatorSize: CGSize = CGSize(width: 18.0, height: 18.0)
        
        /// `axis == .vertical` 时指示器描边线宽
        public var verticalLineWidth: CGFloat = 3.0

        /// `axis == .horizontal` 时指示器描边线宽
        public var horizontalLineWidth: CGFloat = 2.0
        
        // MARK: - 消息文案
        
        /// 消息文字颜色
        public var messageColor: UIColor = .white
        
        /// 消息文字对齐方式
        public var messageAlignment: NSTextAlignment = .natural

        /// 消息文字字体
        public var messageFont: UIFont = .systemFont(ofSize: 16.0, weight: .regular)
    }
    
    
    
    /// HUD 显示位置（顶/底相对 `safeAreaLayoutGuide`，见 `updateContainerViewConstraints`）
    enum Location: Equatable {
        
        /// 顶部：`offset` 为在安全区顶边基础上的额外下移（向内留白，单位 pt）
        case top(offset: CGFloat)
        
        /// 居中
        case center(offset: CGFloat)
        
        /// 底部：`offset` 为在安全区底边基础上的额外上移（向内留白，单位 pt）
        case bottom(offset: CGFloat)
        
        /// 顶部，与安全区顶对齐（附加偏移 0）
        public static var top: Self { .top(offset: 0) }
        
        /// 居中
        public static var center: Self { .center(offset: 0.0) }
        
        /// 底部，与安全区底对齐（附加偏移 0）
        public static var bottom: Self { .bottom(offset: 0) }
        
        /// 默认居中
        public static var `default`: Self { .center }
    }
}



// MARK: - 指示器

public extension ZHHProgressHUD {
        
    /// 活动指示器类型
    enum ActivityIndicatorType: String {
        
        /// 不展示指示器（内部占位 raw 值，解析不到具体实现类）
        case none = "-100000"
        
        /// 默认样式：渐变圆环旋转，对应 `GradientCircleActivityIndicator`
        case `default` = "GradientCircle"
        
        /// 系统 `UIActivityIndicatorView`（大号样式）
        case system = "System"
        
        /// 完整圆环描边，旋转并带动描边起止变化
        case circle = "Circle"
                
        /// 带缺口的圆环（非闭合），整体旋转
        case imperfectCircle = "ImperfectCircle"
        
        /// 半圆弧，描边区间与旋转组合动画
        case halfCircle = "HalfCircle"
        
        /// 圆周上多点，缩放与透明度错相循环（视觉非对称）
        case asymmetricFadeCircle = "AsymmetricFadeCircle"
        
        /// 横向排列的圆点脉冲缩放
        case pulse = "Pulse"

        /// 按 `rawValue` + `ActivityIndicator` 解析对应实现类并实例化；无匹配类时为 `nil`
        fileprivate var indicator: BaseActivityIndicator? {
            BaseActivityIndicator.asIndicator("\(rawValue)ActivityIndicator")
        }
    }
         
    /// 设置活动指示器
    /// - Parameter indicatorType: 指示器类型
    func setActivity(_ indicatorType: ActivityIndicatorType) {
        let activityIndicator = indicatorType.indicator
        if let oldValue = self.activityIndicator,
           let newValue = activityIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        self.activityIndicator = activityIndicator
    }
    
    
    
    /// 进度指示器类型
    enum ProgressIndicatorType: String {
        
        /// 默认：完整圆环轨道，前景弧随进度变化，中心显示百分比文字
        case `default` = "Default"
        
        /// 半圆弧旋转动画（与活动态 `halfCircle` 同类），中心以文字显示进度百分比
        case halfCircle = "HalfCircle"

        /// 按 `rawValue` + `ProgressIndicator` 解析对应实现类并实例化；无匹配类时为 `nil`
        fileprivate var indicator: BaseActivityIndicator? {
            BaseActivityIndicator.asIndicator("\(rawValue)ProgressIndicator")
        }
    }

    /// 设置进度指示器
    /// - Parameters:
    ///   - progressValue: 进度值 [0, 1]
    ///   - indicatorType: 指示器类型
    func setProgress(_ progressValue: CGFloat, indicatorType: ProgressIndicatorType = .default) {
        defer {
            progress = progressValue
        }
        let progressIndicator = indicatorType.indicator
        if let oldValue = activityIndicator,
           let newValue = progressIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        activityIndicator = progressIndicator
    }
    
    
    
    /// HUD 状态（对勾 / 叉号路径动画），命名与 `Result` 的 `.success` / `.failure` 一致
    enum State {
        /// 成功，绘制对勾
        case success
        /// 失败，绘制叉号
        case failure
    }
    
    /// 设置状态指示
    /// - Parameter state: `.success` 或 `.failure`
    func setState(_ state: State) {
        if let oldValue = activityIndicator as? StateIndicator,
           oldValue.state == state {
            return
        }
        activityIndicator = StateIndicator(state: state)
    }
}



// MARK: - 静态

public extension ZHHProgressHUD {
   
    private static let shared = ZHHProgressHUD()

    /// 默认配置
    static var configuration = Configuration()
   
    /// 是否正在显示
    static var isVisible: Bool {
        shared.superview != nil
    }
   
    /// 获取指定容器视图上显示的 HUD
    /// - Parameter containerView: 容器视图
    /// - Returns: HUD 对象
    @discardableResult
    static func hud(from containerView: UIView) -> ZHHProgressHUD? {
        containerView.subviews.first(where: { $0 is ZHHProgressHUD }) as? ZHHProgressHUD
    }
    
    
    
    // MARK: - 展示
    
    /// 展示 HUD：先对单例 `shared` 套用全局 `configuration`，再在闭包内完成实例配置，最后挂到指定父视图或当前前台窗口。
    ///
    /// - Parameters:
    ///   - windowView: 父视图；为 `nil` 时与实例方法 `show(transitionStyle:)` 相同，使用 `UIApplication.shared.currentWindow`。
    ///   - transitionStyle: 出现与消失的转场样式。
    ///   - configureBlock: 展示前配置 `shared`（如 `message`、`location`、`setActivity` 等）。
    static func show(in windowView: UIView? = nil, transitionStyle: TransitionStyle = .default, configureBlock: @escaping (ZHHProgressHUD) -> Void) {
        shared.configuration = Self.configuration
        configureBlock(shared)
        if let windowView = windowView {
            shared.show(in: windowView, transitionStyle: transitionStyle)
        } else {
            shared.show(transitionStyle: transitionStyle)
        }
    }
    
    /// 立即隐藏 HUD
    static func hide() {
        guard isVisible else {
            return
        }
        shared.hide()
    }
    
    /// 延迟隐藏 HUD
    /// - Parameter delay: 延迟时间，默认 0.2 秒
    static func hideAfterDelay(_ delay: TimeInterval = 0.2) {
        guard isVisible else {
            return
        }
        shared.hideAfterDelay(delay)
    }
    
    /// 展示 Toast.
    ///
    /// - Parameters:
    ///    - message: 消息
    ///   - transitionStyle: 转场样式
    static func showToast(_ message: String, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.activityIndicator = nil
            $0.icon = nil
        }
    }
    
    /// 展示图文 Toast：可选文案 + 左侧 `icon`，无加载指示器；走与 `show(transitionStyle:configureBlock:)` 相同的单例展示逻辑。
    ///
    /// - Parameters:
    ///   - message: 说明文字，可为 `nil`。
    ///   - image: 左侧图标，赋给 `icon`，可为 `nil`。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func show(message: String? = nil, image: UIImage? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = image
            $0.activityIndicator = nil
        }
    }
    
    /// 展示成功态 HUD：内置对勾路径动画，清空自定义 `icon`，可选附带说明文案。
    ///
    /// - Parameters:
    ///   - message: 说明文字，可为 `nil`（仅显示对勾）。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func showSuccess(_ message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.icon = nil
            $0.message = message
            $0.setState(.success)
        }
    }
    
    /// 展示失败态 HUD：内置叉号路径动画，清空自定义 `icon`，可选附带说明文案。
    ///
    /// - Parameters:
    ///   - message: 说明文字，可为 `nil`（仅显示叉号）。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func showFailure(_ message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setState(.failure)
        }
    }
    
    /// 展示 HUD 并挂载自定义活动指示器：传入遵循 `ZHHActivityIndicating` 的实例（含库外子类）；若单例上已是同一类型实例则不在闭包内重复替换。
    ///
    /// - Parameters:
    ///   - activityIndicator: 要显示的活动指示器实现。
    ///   - message: 底部说明文案，可为 `nil`。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func showIndicator(_ activityIndicator: ZHHActivityIndicating, message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            if let oldValue = $0.activityIndicator,
               type(of: oldValue.self) == type(of: activityIndicator.self) {
                return
            }
            $0.activityIndicator = activityIndicator
        }
    }
    
    /// 展示 HUD 并使用内置 `ActivityIndicatorType`：清空自定义 `icon`，通过 `setActivity` 创建对应指示器。
    ///
    /// - Parameters:
    ///   - indicatorType: 内置枚举样式，默认 `.default`。
    ///   - message: 底部说明文案，可为 `nil`。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func showIndicator(_ indicatorType: ActivityIndicatorType = .default, message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setActivity(indicatorType)
        }
    }
    
    /// 展示进度 HUD：`progress` 建议 `0…1`，清空 `icon`，按 `ProgressIndicatorType` 创建进度指示器并可选附带说明文案。
    ///
    /// - Parameters:
    ///   - progress: 当前进度，建议取 `0…1`。
    ///   - indicatorType: 内置进度样式，默认 `.default`。
    ///   - message: 底部说明文案，可为 `nil`。
    ///   - transitionStyle: 出现与消失的转场样式。
    static func showProgress(_ progress: CGFloat, indicatorType: ProgressIndicatorType = .default, message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setProgress(progress, indicatorType: indicatorType)
        }
    }
    
    
    
    // MARK: - 创建 HUD

    /// 新建 `ZHHProgressHUD` 并展示：写入 `message`、`location` 后调用 `show`；走独立实例而非静态 `show` 闭包里的单例。
    ///
    /// - Parameters:
    ///   - message: 展示文案。
    ///   - location: 纵向位置，默认 `.bottom`（相对安全区，见 `Location`）。
    ///   - transitionStyle: 出现与消失的转场样式。
    /// - Returns: 已展示的实例，可继续改属性或调用实例方法 `hide`。
    @discardableResult
    static func makeToast(_ message: String, location: Location = .bottom, transitionStyle: TransitionStyle = .default) -> ZHHProgressHUD {
        let hud = ZHHProgressHUD()
        hud.location = location
        hud.message = message
        hud.show(transitionStyle: transitionStyle)
        return hud
    }
}



// MARK: - 私有构造

private extension ZHHProgressHUD {
    
    /// 创建毛玻璃容器视图
    static func makeContainerView() -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView(effect: nil)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }
    
    /// 创建内容堆栈视图
    static func makeContentStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.insetsLayoutMarginsFromSafeArea = false
        return stackView
    }
    
    /// 创建指示器容器（图片视图）
    func makeIconView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    /// 创建消息标签
    func makeMessageLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }
}
