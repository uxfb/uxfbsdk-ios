//
//  YoHeSwiftUI.swift
//  UX Feedback SDK
//
//  Created by Alexander Potemka on 03.02.2025.
//  Copyright © 2025 UXF. All rights reserved.
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
