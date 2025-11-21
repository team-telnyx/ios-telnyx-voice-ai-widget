//
//  TranscriptScrollView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// iOS 13 compatible scroll view with auto-scroll to bottom using GeometryReader
struct TranscriptScrollView: View {
    let transcriptItems: [TranscriptItem]
    let settings: WidgetSettings
    let customization: WidgetCustomization?

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(transcriptItems) { item in
                        TranscriptMessageBubble(item: item, settings: settings, customization: customization)
                    }
                }
                .padding(16)
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear.preference(
                            key: ContentHeightPreferenceKey.self,
                            value: contentGeometry.size.height
                        )
                    }
                )
            }
            .onPreferenceChange(ContentHeightPreferenceKey.self) { contentHeight in
                // Auto-scroll to bottom when content height changes
                if contentHeight > geometry.size.height {
                    DispatchQueue.main.async {
                        scrollOffset = contentHeight - geometry.size.height
                    }
                }
            }
        }
    }
}

/// Preference key to track content height for auto-scrolling
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
