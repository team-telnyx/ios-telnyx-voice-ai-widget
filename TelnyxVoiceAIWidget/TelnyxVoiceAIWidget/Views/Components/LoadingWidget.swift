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
                    .fill(Color.accentColor)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 4)

                ActivityIndicator(color: .white)
                    .scaleEffect(1.2)
            }
        } else {
            HStack(spacing: 12) {
                ActivityIndicator(color: .systemBlue)

                Text("Connecting...")
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(24)
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