//
//  AppDelegate.swift
//  tet
//
//  Created by Evelyne Suto on 17.01.2023.
//

// Note: Setup Appdelegate and SceneDelegate
// https://betterprogramming.pub/an-introduction-to-coordinator-pattern-in-swiftui-38e5b02f031f
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sessionRole = connectingSceneSession.role
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: sessionRole)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}
