//
//  AudioVisualizer.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Audio visualizer component showing audio levels
struct AudioVisualizer: View {
    let audioLevels: [Float]
    let color: Color
    
    init(audioLevels: [Float], color: Color = .blue) {
        self.audioLevels = audioLevels
        self.color = color
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(color.opacity(0.7))
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(.easeInOut(duration: 0.1), value: audioLevels)
            }
        }
        .frame(height: 30)
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let level = index < audioLevels.count ? audioLevels[index] : 0.0
        return max(2, CGFloat(level) * 30)
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioVisualizer(
            audioLevels: Array(0..<20).map { _ in Float.random(in: 0...1) }
        )
        
        AudioVisualizer(
            audioLevels: Array(0..<20).map { _ in Float.random(in: 0...1) },
            color: .green
        )
    }
    .padding()
}