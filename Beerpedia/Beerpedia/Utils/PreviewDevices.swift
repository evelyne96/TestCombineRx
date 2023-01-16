//
//  PreviewDevices.swift
//  Beerpedia
//
//  Created by Evelyne Suto on 16.01.2023.
//

import Foundation
import SwiftUI

enum Devices: String {
    case iPhone14 = "iPhone 14"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPadMini = "iPad mini (6th generation)"
    
    var preview: PreviewDevice {
        PreviewDevice(rawValue: rawValue)
    }
    
    var name: String { rawValue }
}
