//
//  LoadingWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Loading widget component
struct LoadingWidget: View {
    let isCircular: Bool
    
    init(isCircular: Bool = false) {
        self.isCircular = isCircular
    }
    
    var body: some View {
        if isCircular {
            // Circular loading for icon-only mode
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 56, height: 56)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }
        } else {
            // Regular loading widget
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.blue)
                .frame(height: 56)
                .overlay(
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text("Loading...")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingWidget()
            .padding()
        
        LoadingWidget(isCircular: true)
            .padding()
    }
}