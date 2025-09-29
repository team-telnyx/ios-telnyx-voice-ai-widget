//
//  AudioVisualizer.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Audio visualizer component that displays real-time audio levels
struct AudioVisualizer: View {
    let audioLevels: [Float]
    private let barCount = 20
    private let minHeight: CGFloat = 4
    private let maxHeight: CGFloat = 60

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.accentColor.opacity(0.6), .accentColor]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(
                            width: barWidth(for: geometry.size.width),
                            height: barHeight(for: index)
                        )
                        .animation(.easeInOut(duration: 0.1), value: audioLevels)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let totalSpacing = CGFloat(barCount - 1) * 2
        return (totalWidth - totalSpacing) / CGFloat(barCount)
    }

    private func barHeight(for index: Int) -> CGFloat {
        guard !audioLevels.isEmpty else {
            return minHeight
        }

        let levelIndex = index % audioLevels.count
        let level = CGFloat(audioLevels[levelIndex])

        // Clamp between 0 and 1
        let clampedLevel = max(0, min(1, level))

        // Interpolate between min and max height
        return minHeight + (maxHeight - minHeight) * clampedLevel
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Active Audio")
            .font(.caption)
        AudioVisualizer(audioLevels: [0.3, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3, 0.6, 0.8, 0.7, 0.5, 0.4, 0.6, 0.9, 0.7, 0.5, 0.3, 0.4])
            .frame(height: 60)
            .padding()

        Text("Low Audio")
            .font(.caption)
        AudioVisualizer(audioLevels: [0.1, 0.2, 0.15, 0.1, 0.2, 0.1, 0.15, 0.2, 0.1, 0.15])
            .frame(height: 60)
            .padding()

        Text("No Audio")
            .font(.caption)
        AudioVisualizer(audioLevels: [])
            .frame(height: 60)
            .padding()
    }
}