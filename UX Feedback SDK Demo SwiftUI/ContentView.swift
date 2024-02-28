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
    var body: some View {
        VStack {
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
