//
//  ExampleDemoViewModel.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit
import ZHHProgressHUD

/// 示例列表分组（对应 UITableView section）
struct ExampleDemoTableSection {
    /// 分组标题
    let title: String
    /// 行数据
    let items: [ExampleDemoTableItem]
}

/// 示例列表一行（标题 + 点击行为）
struct ExampleDemoTableItem {
    /// 行标题
    let title: String
    /// 选中时执行的 HUD 演示
    let onSelect: () -> Void
}

/// 示例数据与 ZHHProgressHUD 调用逻辑，与控制器解耦（MVVM 中的 VM）
final class ExampleDemoViewModel {

    /// 用于从界面层解析当前 `UIWindow`，便于 `hud(from:)` 与进度演示
    private let keyWindow: () -> UIWindow?
    /// 进度条模拟定时器，需在切换演示或关闭时作废
    private var progressTimer: Timer?

    /// - Parameter keyWindow: 返回当前界面所在窗口（一般为 `view.window`）
    init(keyWindow: @escaping () -> UIWindow?) {
        self.keyWindow = keyWindow
    }

    /// 表格数据源（首次访问时构建）
    lazy var sections: [ExampleDemoTableSection] = makeSections()

    /// 停止进度模拟，避免与后续演示冲突
    func invalidateProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    /// 关闭 HUD 并清理进度定时器（如导航栏取消）
    func dismissAllHUD() {
        invalidateProgressTimer()
        ZHHProgressHUD.hide()
    }

    /// 展示进度 HUD 并用定时器递增进度直至完成
    private func startProgress(from value: CGFloat, indicatorType: ZHHProgressHUD.ProgressIndicatorType) {
        // 避免与上一次进度演示的 Timer 叠加
        invalidateProgressTimer()
        // 静态 API：在 KeyWindow 上展示进度 HUD（单例 shared），指定初始进度与样式
        ZHHProgressHUD.showProgress(value, indicatorType: indicatorType, message: "加载中")
        // 从当前窗口取正在展示的 HUD，用于读取 progress；取不到则无法驱动定时更新
        guard let window = keyWindow(), let hud = ZHHProgressHUD.hud(from: window) else { return }
        // 高频刷新进度数值，模拟异步任务推进（仅示例，业务里应绑定真实任务进度）
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] t in
            let next = hud.progress + 0.002
            // 每次更新进度都会走静态 showProgress，内部会刷新同一 HUD 的进度与文案
            ZHHProgressHUD.showProgress(next, indicatorType: indicatorType, message: "加载中")
            if next >= 1.0 {
                // 满进度后切到成功态（图标+文案），随后由库的自动隐藏逻辑收起
                ZHHProgressHUD.showSuccess("加载成功")
                t.invalidate()
                self?.progressTimer = nil
            }
        }
        // 滚动等模式下普通 default 模式的 RunLoop 可能不触发 Timer，挂到 common 更稳
        RunLoop.main.add(timer, forMode: .common)
        progressTimer = timer
    }

    /// 与 `Demo/ViewController` 列表与文案对齐（库名为 ZHHProgressHUD）
    private func makeSections() -> [ExampleDemoTableSection] {
        [
            ExampleDemoTableSection(title: "Toast 示例", items: [
                ExampleDemoTableItem(title: "Toast（便捷·纯文案）", onSelect: {
                    // 静态便捷：仅文案、无指示器，走默认转场与自动隐藏
                    ZHHProgressHUD.showToast("这是一条纯文案 Toast，会自动消失。")
                }),
                ExampleDemoTableItem(title: "Toast（短文案·半透明毛玻璃·拦截点击）", onSelect: {
                    // 实例方式：可逐项改 configuration，再 show 到 KeyWindow
                    let hud = ZHHProgressHUD()
                    // configuration 与根视图 `isUserInteractionEnabled` 取反：为 false 时根视图为 true，全屏遮罩拦截点击；默认 true 时可穿透
                    hud.configuration.isUserInteractionEnabled = false
                    hud.configuration.dimmingColor = UIColor.black.withAlphaComponent(0.8)
                    hud.configuration.backgroundEffect = UIBlurEffect(style: .prominent)
                    hud.location = .bottom
                    hud.configuration.messageColor = .black
                    hud.message = "背后半透明+毛玻璃，点击无法穿透到下层界面。"
                    hud.show(transitionStyle: .fade)
                }),
                ExampleDemoTableItem(title: "Toast（长文案·底栏·拦截点击）", onSelect: {
                    let hud = ZHHProgressHUD()
                    hud.configuration.isUserInteractionEnabled = false
                    hud.location = .bottom
                    // 长文案：观察多行换行与容器随内容变宽变高（与 minimumSize 等配置有关）；`isUserInteractionEnabled == false` 时同样拦截点击
                    hud.message = "这是一段故意写得很长的提示文案，用来观察多行换行、最大宽度比例以及内边距在窄屏上的表现；你可以把它当成产品说明、协议摘要或任何需要占多行的场景。"
                    hud.show()
                })
            ]),
            // 成功 / 失败 / 图文：静态 API，内部用 StateIndicator 或纯展示
            ExampleDemoTableSection(title: "成功与失败", items: [
                ExampleDemoTableItem(title: "成功（仅对勾）", onSelect: {
                    // 仅对勾图标，无文案
                    ZHHProgressHUD.showSuccess()
                }),
                ExampleDemoTableItem(title: "成功（短文案）", onSelect: {
                    // 对勾 + 一行说明
                    ZHHProgressHUD.showSuccess("操作已完成")
                }),
                ExampleDemoTableItem(title: "失败（仅叉号）", onSelect: {
                    // 仅叉号图标，无文案
                    ZHHProgressHUD.showFailure()
                }),
                ExampleDemoTableItem(title: "失败（短文案）", onSelect: {
                    // 叉号 + 一行说明
                    ZHHProgressHUD.showFailure("未成功，请重试")
                }),
                ExampleDemoTableItem(title: "图文（便捷方法）", onSelect: {
                    // 文案 + 左侧图，无加载/状态图标
                    ZHHProgressHUD.show(message: "左侧为示意图片", image: UIImage(named: "ic_user_avatar_default"))
                })
            ]),
            // 加载菊花：静态 showIndicator，第二参数为底部说明文案
            ExampleDemoTableSection(title: "竖向加载样式", items: [
                ExampleDemoTableItem(title: "渐变圆环（默认）", onSelect: {
                    // 默认渐变圆环
                    ZHHProgressHUD.showIndicator(.default, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "系统菊花", onSelect: {
                    // UIActivityIndicatorView
                    ZHHProgressHUD.showIndicator(.system, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "完整圆环", onSelect: {
                    // 完整圆环描边
                    ZHHProgressHUD.showIndicator(.circle, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "缺口圆环", onSelect: {
                    // 缺一段的圆环
                    ZHHProgressHUD.showIndicator(.imperfectCircle, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "半圆弧", onSelect: {
                    // 半圆弧旋转
                    ZHHProgressHUD.showIndicator(.halfCircle, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "圆周多点（缩放·渐隐）", onSelect: {
                    // 两端透明度不对称的圆环
                    ZHHProgressHUD.showIndicator(.asymmetricFadeCircle, message: "正在加载")
                }),
                ExampleDemoTableItem(title: "三点脉冲", onSelect: {
                    // 缩放脉冲环
                    ZHHProgressHUD.showIndicator(.pulse, message: "正在加载")
                })
            ]),
            ExampleDemoTableSection(title: "进度模拟", items: [
                ExampleDemoTableItem(title: "默认进度（渐变圆环）", onSelect: { [weak self] in
                    // 见 `startProgress`：定时器模拟进度，满格后 showSuccess
                    self?.startProgress(from: 0, indicatorType: .default)
                }),
                ExampleDemoTableItem(title: "半圆弧进度", onSelect: { [weak self] in
                    self?.startProgress(from: 0, indicatorType: .halfCircle)
                })
            ]),
            // 横排布局 + 实例 API 组合（图标与文字同一行）
            ExampleDemoTableSection(title: "横排示例", items: [
                ExampleDemoTableItem(title: "加载（横排·默认菊花）", onSelect: {
                    let hud = ZHHProgressHUD()
                    hud.configuration.isUserInteractionEnabled = false
                    hud.axis = .horizontal
                    hud.message = "正在加载..."
                    hud.setActivity(.default)
                    hud.show()
                    // 非自动隐藏类指示器，需手动延时关闭
                    hud.hideAfterDelay(3.0)
                }),
                ExampleDemoTableItem(title: "成功提示（横排·对勾）", onSelect: {
                    let hud = ZHHProgressHUD()
                    hud.configuration.isUserInteractionEnabled = false
                    hud.axis = .horizontal
                    hud.message = "操作成功"
                    // 替换为内置成功路径动画（对勾）
                    hud.setState(.success)
                    hud.show()
                }),
                ExampleDemoTableItem(title: "图文（横排·自定义图）", onSelect: {
                    let hud = ZHHProgressHUD()
                    hud.configuration.isUserInteractionEnabled = false
                    hud.axis = .horizontal
                    hud.message = "Smiling"
                    // 自定义图走 icon，尺寸受 horizontalIndicatorSize 约束
                    hud.icon = UIImage(named: "ic_user_avatar_default")
                    hud.show()
                }),
                ExampleDemoTableItem(title: "顶栏横条（图文·左对齐）", onSelect: {
                    let hud = ZHHProgressHUD()
                    hud.configuration.isUserInteractionEnabled = false
                    hud.configuration.maxWidthPercentage = 0.95
                    hud.configuration.messageAlignment = .left
                    hud.configuration.horizontalIndicatorSize = CGSize(width: 35, height: 35)
                    hud.location = .top
                    hud.axis = .horizontal
                    hud.message = "Emoji"
                    hud.icon = UIImage(named: "ic_user_avatar_default")
                    // 顶栏横条图文：宽上限与左对齐配合长文案/多语言
                    hud.show()
                })
            ])
        ]
    }
}
