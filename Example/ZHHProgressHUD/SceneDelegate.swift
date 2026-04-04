//
//  SceneDelegate.swift
//  ZHHProgressHUD
//
//  Created by 桃色三岁 on 2026/4/4.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: ExampleDemoViewController())
        window.makeKeyAndVisible()
        self.window = window
    }
}
