//
//  UIApplication+Window.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2021/3/3.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// 当前窗口（优先前台激活场景下的 keyWindow）
    var currentWindow: UIWindow? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        
        for scene in windowScenes where scene.activationState == .foregroundActive {
            if let key = scene.windows.first(where: \.isKeyWindow) {
                return key
            }
        }
        for scene in windowScenes {
            if let key = scene.windows.first(where: \.isKeyWindow) {
                return key
            }
        }
        return nil
    }
}
