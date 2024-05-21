//
//  UXFeedbackSwiftUI.swift
//  UXFeedbackSDK
//
//  Created by Alexander Potemka on 14.02.2024.
//  Copyright © 2024 UXF. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct CampaignViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CampaignViewController
    
    func makeUIViewController(context: Context) -> CampaignViewController {
        let viewController = CampaignViewController()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CampaignViewController, context: Context) {
        
    }
}
