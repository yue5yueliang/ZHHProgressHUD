# ZHHProgressHUD

iOS 全局 **HUD / Toast**：纯文案 Toast、图文提示、加载与进度、成功/失败态；毛玻璃容器、顶/中/底位置、多种转场；通过 `Configuration` 统一改样式。

## 环境要求

- iOS **15.0+**
- Swift **5.0+**
- 无第三方依赖（UIKit、QuartzCore）

## 安装（CocoaPods）

在 `Podfile` 中：

```ruby
platform :ios, '15.0'

pod 'ZHHProgressHUD', '~> 0.0.1'
```

执行 `pod install`。

## 示例工程

```bash
cd Example
pod install
open ZHHProgressHUD.xcworkspace
```

## 用法摘要

```swift
// 全局默认样式（可选，在启动时设置一次）
ZHHProgressHUD.configuration.messageFont = .systemFont(ofSize: 15)

// Toast（纯文案，默认自动消失）
ZHHProgressHUD.showToast("操作成功")

// 图文
ZHHProgressHUD.show(message: "已保存", image: UIImage(named: "icon"))

// 加载
ZHHProgressHUD.showIndicator(message: "加载中…")
ZHHProgressHUD.hide()

// 成功 / 失败
ZHHProgressHUD.showSuccess("完成")
ZHHProgressHUD.showFailure("失败")

// 独立实例（非单例）
let hud = ZHHProgressHUD.makeToast("底部提示", location: .bottom)
```

更多能力见源码中 `ZHHProgressHUD` 对外 API（`show(in:configureBlock:)`、`location`、`transitionStyle`、`progress` 等）。

## 发布前自检

```bash
pod lib lint ZHHProgressHUD.podspec --allow-warnings
```

## 作者

桃色三岁，136769890@qq.com

## 许可

MIT，见 [LICENSE](LICENSE)。
