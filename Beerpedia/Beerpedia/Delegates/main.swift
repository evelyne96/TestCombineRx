//
//  main.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 23.01.2023.
//

import UIKit

let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? nil : NSStringFromClass(AppDelegate.self)
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegateClass)
