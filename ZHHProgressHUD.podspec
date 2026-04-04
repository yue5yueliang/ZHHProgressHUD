#
# 发布前请执行: pod lib lint ZHHProgressHUD.podspec
#

Pod::Spec.new do |s|
  s.name             = 'ZHHProgressHUD'
  s.version          = '0.0.1'
  s.summary          = 'iOS 全局 HUD / Toast：加载、进度、成功失败态、毛玻璃与可配置转场。'

  s.description      = <<-DESC
ZHHProgressHUD 提供覆盖在窗口上的 HUD 与 Toast 能力：纯文案 Toast、图文提示、内置活动指示器与进度、
成功/失败状态动画；支持顶/中/底位置、横竖布局、多种转场样式与全局/单例 `Configuration` 外观配置。
无第三方依赖，仅依赖系统 UIKit / QuartzCore。
                       DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHProgressHUD'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHProgressHUD.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version         = '5.0'

  s.source_files = 'ZHHProgressHUD/Classes/**/*'
  s.frameworks   = 'UIKit', 'QuartzCore'
end
