//
//  AppDelegate.swift
//  WoodenFish
//
//  Created by zhanghao on 2024/1/24.
//

import UIKit
import FluentDarkModeKit
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initWindow()
        initDarkModel()
        initIQKeyboard()
        return true
    }
    func initIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarBarTintColor = UIColor(.dm,light: .tableViewBgC,dark: .tableViewBgC_dark)
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
    }
    func initWindow() {
        if #available(iOS 13.0, *) {
            window = UIWindow.init(frame: UIScreen.main.bounds)
            window?.rootViewController = UITabBarController()
            window?.backgroundColor = .white
            window?.makeKeyAndVisible()
        }
        
        let nav = QMUINavigationController.init(rootViewController: ZHMuYuViewController())
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    //    初始化主题—
    func initDarkModel() {
        let configuration = DMEnvironmentConfiguration()
        configuration.themeChangeHandler = {
            print("theme changed")
        }
        if #available(iOS 13.0, *) {
            configuration.windowThemeChangeHandler = { window in
                print("\(window) theme changed")
            }
            configuration.useImageAsset = false
        }
        DarkModeManager.setup(with: configuration)
        DarkModeManager.register(with: UIApplication.shared)
        
    }
    
    
    
}

