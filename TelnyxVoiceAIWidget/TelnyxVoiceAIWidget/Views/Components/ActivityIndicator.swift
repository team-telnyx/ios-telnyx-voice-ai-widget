//
//  ActivityIndicator.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// UIKit-based activity indicator compatible with iOS 13+
struct ActivityIndicator: UIViewRepresentable {
    let color: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = color
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.color = color
    }
}
