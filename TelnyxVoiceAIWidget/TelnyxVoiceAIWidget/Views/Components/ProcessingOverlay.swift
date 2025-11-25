//
//  ProcessingOverlay.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Overlay shown while waiting for call to end and URL to open
struct ProcessingOverlay: View {
    let colorResolver: ColorResolver

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            // Loading indicator
            VStack(spacing: 16) {
                ActivityIndicator(color: .white)
                    .frame(width: 40, height: 40)

                Text("Ending call...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
        }
    }
}
