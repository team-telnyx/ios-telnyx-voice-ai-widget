//
//  TranscriptScrollView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Scroll view with intelligent auto-scroll behavior
struct TranscriptScrollView: View {
    let transcriptItems: [TranscriptItem]
    let settings: WidgetSettings
    let customization: WidgetCustomization?
    let shouldScrollToBottom: Bool

    @State private var isUserScrolling = false
    @State private var hasScrolledManually = false
    @State private var scrollViewContentHeight: CGFloat = 0

    var body: some View {
        if #available(iOS 14.0, *) {
            modernScrollView
        } else {
            legacyScrollView
        }
    }

    // MARK: - iOS 14+ Implementation with ScrollViewReader
    @available(iOS 14.0, *)
    private var modernScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(transcriptItems) { item in
                        TranscriptMessageBubble(item: item, settings: settings, customization: customization)
                            .id(item.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).origin.y
                    )
                }
            )
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Detect if user is manually scrolling (scrolling up)
                if value > 50 {
                    hasScrolledManually = true
                }
            }
            .onChange(of: transcriptItems.count) { _ in
                // Auto-scroll when new messages arrive, unless user has scrolled manually
                if !hasScrolledManually && shouldScrollToBottom {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: shouldScrollToBottom) { newValue in
                // Force scroll to bottom when explicitly requested (e.g., sending message or keyboard shown)
                if newValue {
                    hasScrolledManually = false
                    scrollToBottom(proxy: proxy)
                }
            }
            .onAppear {
                // Scroll to bottom on initial load
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }

    // MARK: - iOS 13 Compatible Implementation
    private var legacyScrollView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(transcriptItems) { item in
                        TranscriptMessageBubble(item: item, settings: settings, customization: customization)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            .frame(width: geometry.size.width)
            .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                scrollViewContentHeight = height
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                // Handle keyboard appearance for iOS 13
                if shouldScrollToBottom {
                    hasScrolledManually = false
                }
            }
        }
    }

    @available(iOS 14.0, *)
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastItem = transcriptItems.last else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo(lastItem.id, anchor: .bottom)
        }
    }
}

/// Preference key to track scroll offset for detecting manual scrolling
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Preference key to track content height for iOS 13 compatibility
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
