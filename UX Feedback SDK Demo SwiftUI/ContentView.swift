//
//  ContentView.swift
//  UX Feedback SDK Demo SwiftUI
//
//  Created by Alexander Potemka on 14.02.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import SwiftUI
import UXFeedbackSDK

struct ContentView: View {
  @State private var blurPopupColor = Color(hex: "#\(UXFeedback.sdk.settings.popupUiBlackoutColor ?? "000000")")
  @State private var blurSlideinColor = Color(hex: "#\(UXFeedback.sdk.settings.slideInUiBlackoutColor ?? "000000")")
  
  var body: some View {
    VStack {
      ColorPicker("Set the blur popup color", selection: $blurPopupColor)
        .padding(.vertical, 4)
      
      ColorPicker("Set the blur slidein color", selection: $blurSlideinColor)
        .padding(.vertical, 4)
      
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      
      Text("UXFeedback SwiftUI\nAppId = ckzxywct400003965yjfzyp5m\nenvironment = dev")
        .padding(.vertical, 5)
        .multilineTextAlignment(.center)
      
      Button("Button to load") {
        let settings = UXFBSettings()
        settings.debugEnabled = true
        
        let theme = UXFBTheme()
        theme.bgColor = .darkText
        UXFeedback.setup(appID: "ckzxywct400003965yjfzyp5m", settings: settings)
      }
      .padding(.vertical, 5)
      
      Button("Button to present") {
        UXFeedback.sdk.settings.closeOnSwipe = true
        UXFeedback.sdk.settings.slideInUiBlocked = true
        UXFeedback.sdk.settings.slideInUiBlackoutBlur = 4
        UXFeedback.sdk.settings.slideInUiBlackoutOpacity = 50
        UXFeedback.sdk.settings.slideInUiBlackoutColor = "000000"
        UXFeedback.sdk.settings.popupUiBlackoutBlur = 4
        UXFeedback.sdk.settings.popupUiBlackoutOpacity = 50
        UXFeedback.sdk.settings.popupUiBlackoutColor = "000000"
        
        UXFeedback.sdk.startCampaign(eventName: "swagger")
      }
      .padding(.vertical, 5)
    }
    
    .padding()
  }
}

//#Preview {
//    ContentView()
//}
