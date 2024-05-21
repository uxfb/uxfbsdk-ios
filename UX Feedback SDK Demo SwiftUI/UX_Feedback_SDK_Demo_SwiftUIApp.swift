//
//  UX_Feedback_SDK_Demo_SwiftUIApp.swift
//  UX Feedback SDK Demo SwiftUI
//
//  Created by Alexander Potemka on 14.02.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
  init(hex: String) {
    var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
    print(cleanHexCode)
    var rgb: UInt64 = 0
    
    Scanner(string: cleanHexCode).scanHexInt64(&rgb)
    
    let redValue = Double((rgb >> 16) & 0xFF) / 255.0
    let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
    let blueValue = Double(rgb & 0xFF) / 255.0
    self.init(red: redValue, green: greenValue, blue: blueValue)
  }
  
  var uiColor: UIColor { .init(self) }
  
  typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
      
  var rgba: RGBA? {
    var (r, g, b, a): RGBA = (0, 0, 0, 0)
    return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r, g, b, a) : nil
  }
  
  var hexaRGB: String? {
    guard let (red, green, blue, _) = self.rgba else { return nil }
    return String(format: "#%02x%02x%02x",
                  Int(red * 255),
                  Int(green * 255),
                  Int(blue * 255))
  }
}

@main
struct UX_Feedback_SDK_Demo_SwiftUIApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
