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
    let colorScheme: String?
    private let barCount: Int = 10
    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(gradientForScheme)
                        .frame(
                            width: barWidth(for: geometry.size.width),
                            height: barHeight(for: index, containerHeight: geometry.size.height)
                        )
                        .animation(.easeInOut(duration: 0.15), value: audioLevels)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    /// Returns the gradient based on the color scheme
    private var gradientForScheme: LinearGradient {
        let colors: [Color] = colorGradient(for: colorScheme)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Returns the color array for a given scheme
    private func colorGradient(for scheme: String?) -> [Color] {
        switch scheme?.lowercased() {
        case "verdant":
            return [.verdantStart, .verdantMid, .verdantEnd]
        case "twilight":
            return [.twilightStart, .twilightMid, .twilightEnd]
        case "bloom":
            return [.bloomStart, .bloomMid, .bloomEnd]
        case "mystic":
            return [.mysticStart, .mysticMid, .mysticEnd]
        case "flare":
            return [.flareStart, .flareMid, .flareEnd]
        case "glacier":
            return [.glacierStart, .glacierMid, .glacierEnd]
        default:
            // Default to verdant
            return [.verdantStart, .verdantMid, .verdantEnd]
        }
    }

    private func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let totalSpacing: CGFloat = CGFloat(barCount - 1) * spacing
        return (totalWidth - totalSpacing) / CGFloat(barCount)
    }

    private func barHeight(for index: Int, containerHeight: CGFloat) -> CGFloat {
        let minHeightRatio: CGFloat = 0.2  // 20% minimum
        let maxHeightRatio: CGFloat = 0.8  // 80% maximum

        guard !audioLevels.isEmpty else {
            // Inactive state: 30% height
            return containerHeight * 0.3
        }

        let levelIndex: Int = index % audioLevels.count
        let level = CGFloat(audioLevels[levelIndex])

        // Clamp between 0 and 1
        let clampedLevel: CGFloat = max(0, min(1, level))

        // Interpolate between min and max ratio
        let heightRatio: CGFloat = minHeightRatio + (maxHeightRatio - minHeightRatio) * clampedLevel

        return containerHeight * heightRatio
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Active Audio - Verdant")
            .font(.caption)
        AudioVisualizer(audioLevels: [0.3, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3, 0.6, 0.8, 0.7, 0.5, 0.4, 0.6, 0.9, 0.7, 0.5, 0.3, 0.4], colorScheme: "verdant")
            .frame(height: 60)
            .padding()

        Text("Low Audio - Bloom")
            .font(.caption)
        AudioVisualizer(audioLevels: [0.1, 0.2, 0.15, 0.1, 0.2, 0.1, 0.15, 0.2, 0.1, 0.15], colorScheme: "bloom")
            .frame(height: 60)
            .padding()

        Text("No Audio - Glacier")
            .font(.caption)
        AudioVisualizer(audioLevels: [], colorScheme: "glacier")
            .frame(height: 60)
            .padding()
    }
}
