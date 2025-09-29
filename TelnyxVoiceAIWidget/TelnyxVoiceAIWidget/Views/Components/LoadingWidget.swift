//
//  LoadingWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Loading widget component
struct LoadingWidget: View {
    var isCircular: Bool = false

    var body: some View {
        if isCircular {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)

                ActivityIndicator(color: UIColor(red: 0x63/255.0, green: 0x66/255.0, blue: 0xF1/255.0, alpha: 1.0))
                    .scaleEffect(0.8)
            }
        } else {
            VStack(spacing: 12) {
                ActivityIndicator(color: UIColor(red: 0x63/255.0, green: 0x66/255.0, blue: 0xF1/255.0, alpha: 1.0))
                    .scaleEffect(1.0)

                Text("Connecting...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.widgetSecondaryTextLight)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingWidget(isCircular: false)
            .padding()

        LoadingWidget(isCircular: true)
            .padding()
    }
}