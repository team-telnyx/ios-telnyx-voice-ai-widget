//
//  TranscriptView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import Combine
import SwiftUI
import UIKit

/// Overflow menu actions
enum OverflowAction {
    case giveFeedback
    case viewHistory
    case reportIssue

    var title: String {
        switch self {
        case .giveFeedback:
            return "Give Feedback"
        case .viewHistory:
            return "View History"
        case .reportIssue:
            return "Report Issue"
        }
    }

    var iconName: String {
        switch self {
        case .giveFeedback:
            return "hand.thumbsup"
        case .viewHistory:
            return "clock"
        case .reportIssue:
            return "exclamationmark.triangle"
        }
    }

    var confirmationTitle: String {
        switch self {
        case .giveFeedback:
            return "End call and give feedback"
        case .viewHistory:
            return "End call and view history"
        case .reportIssue:
            return "End call and report issue"
        }
    }
}

/// Full-screen transcript view component matching Android implementation
struct TranscriptView: View {
    let settings: WidgetSettings
    let customization: WidgetCustomization?
    let transcriptItems: [TranscriptItem]
    let userInput: String
    let isConnected: Bool
    let isMuted: Bool
    let agentStatus: AgentStatus
    let audioLevels: [Float]
    let onUserInputChange: (String) -> Void
    let onSendMessage: () -> Void
    let onSendMessageWithImages: ([UIImage]) -> Void
    let onToggleMute: () -> Void
    let onEndCall: () -> Void
    let onCollapse: () -> Void
    let iconOnly: Bool

    @State private var keyboardHeight: CGFloat = 0
    @State private var attachedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showImageSourceMenu = false
    @State private var capturedImage: UIImage?
    @State private var showOverflowMenu = false
    @State private var showConfirmationDialog = false
    @State private var pendingAction: OverflowAction?

    private var colorResolver: ColorResolver {
        ColorResolver(customization: customization, settings: settings)
    }

    /// Available overflow actions based on widget settings
    private var availableOverflowActions: [OverflowAction] {
        var actions: [OverflowAction] = []

        if settings.giveFeedbackUrl != nil {
            actions.append(.giveFeedback)
        }
        if settings.viewHistoryUrl != nil {
            actions.append(.viewHistory)
        }
        if settings.reportIssueUrl != nil {
            actions.append(.reportIssue)
        }

        return actions
    }

    /// Whether to show the overflow menu button
    private var shouldShowOverflowMenu: Bool {
        !availableOverflowActions.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with controls
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Overflow menu button (on the left)
                        if shouldShowOverflowMenu {
                            Button(action: {
                                showOverflowMenu = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(colorResolver.primaryText())
                                    .frame(width: 40, height: 40)
                            }
                        }

                        Spacer()

                        // Mute button
                        Button(action: onToggleMute) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 18))
                                .foregroundColor(colorResolver.muteButtonIcon(isMuted: isMuted))
                                .frame(width: 40, height: 40)
                                .background(colorResolver.muteButtonBackground(isMuted: isMuted))
                                .clipShape(Circle())
                        }

                        // End call button
                        Button(action: onEndCall) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.red)
                                .clipShape(Circle())
                        }

                        // Close button (only in regular mode)
                        if !iconOnly {
                            Button(action: onCollapse) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(colorResolver.primaryText())
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Audio visualizer and status
                    VStack(spacing: 8) {
                        AudioVisualizer(
                            audioLevels: audioLevels,
                            colorScheme: colorResolver.audioVisualizerColor()
                        )
                        .frame(height: 60)

                        Text(agentStatusText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(colorResolver.secondaryText())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .background(colorResolver.widgetSurface())
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

                // Transcript messages - iOS 13 compatible
                TranscriptScrollView(
                    transcriptItems: transcriptItems,
                    settings: settings,
                    customization: customization
                )
                .frame(maxHeight: .infinity)
                .background(colorResolver.transcriptBackground())

                Divider()

                // Message input area
                VStack(spacing: 8) {
                    // Image previews
                    if !attachedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(attachedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 64, height: 64)
                                            .clipped()
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )

                                        Button(action: {
                                            attachedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                                .font(.system(size: 20))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 72)
                    }

                    HStack(spacing: 12) {
                        // Attachment menu button
                        Button(action: {
                            showImageSourceMenu.toggle()
                        }) {
                            Image(systemName: "paperclip")
                                .font(.system(size: 20))
                                .foregroundColor(colorResolver.primaryText())
                                .frame(width: 32, height: 32)
                        }
                        .disabled(!isConnected)
                        .actionSheet(isPresented: $showImageSourceMenu) {
                            ActionSheet(
                                title: Text("Choose Image Source"),
                                buttons: [
                                    .default(Text("Photo Library")) {
                                        showImagePicker = true
                                    },
                                    .default(Text("Take Photo")) {
                                        showCamera = true
                                    },
                                    .cancel()
                                ]
                            )
                        }

                        TextField(
                            "Type a message...",
                            text: Binding(
                                get: { userInput },
                                set: { onUserInputChange($0) }
                            ),
                            onCommit: {
                                handleSendMessage()
                            }
                        )
                        .foregroundColor(colorResolver.primaryText())
                        .padding(12)
                        .background(colorResolver.inputBackground())
                        .cornerRadius(24)
                        .disabled(!isConnected)

                        Button(action: handleSendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(canSendMessage ? Color.primaryIndigo : Color.slate300)
                        }
                        .disabled(!canSendMessage)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(colorResolver.widgetSurface())
            }
            .frame(width: geometry.size.width, height: geometry.size.height - keyboardHeight)
            .background(colorResolver.widgetSurface())
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
        .overlay(
            Group {
                if showOverflowMenu {
                    OverflowMenuPopup(
                        actions: availableOverflowActions,
                        colorResolver: colorResolver,
                        onActionSelected: { action in
                            showOverflowMenu = false
                            pendingAction = action
                            showConfirmationDialog = true
                        },
                        onDismiss: {
                            showOverflowMenu = false
                        }
                    )
                }
            }
        )
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImages: $attachedImages)
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(capturedImage: $capturedImage) { image in
                attachedImages.append(image)
            }
        }
        .alert(isPresented: $showConfirmationDialog) {
            Alert(
                title: Text(pendingAction?.confirmationTitle ?? ""),
                message: Text("This will end your current call. Do you want to continue?"),
                primaryButton: .default(Text("OK")) {
                    handleConfirmedAction()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            setupKeyboardObservers()
        }
    }

    private var canSendMessage: Bool {
        (!userInput.isEmpty || !attachedImages.isEmpty) && isConnected
    }

    private func handleSendMessage() {
        guard canSendMessage else { return }

        if !attachedImages.isEmpty {
            onSendMessageWithImages(attachedImages)
            attachedImages = []
        } else {
            onSendMessage()
        }
    }

    private var agentStatusText: String {
        switch agentStatus {
        case .idle:
            return "Idle"
        case .thinking:
            return settings.agentThinkingText ?? "Thinking..."
        case .waiting:
            return settings.speakToInterruptText ?? "Speak to interrupt"
        case .processingImage:
            return "Processing image..."
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            keyboardHeight = keyboardFrame.height
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }

    /// Handles the confirmed action after user confirmation
    private func handleConfirmedAction() {
        guard let action = pendingAction else { return }

        // End the call first
        onEndCall()

        // Wait briefly for the call to end, then open the URL
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            openURLForAction(action)
        }

        pendingAction = nil
    }

    /// Opens the appropriate URL for the given action
    private func openURLForAction(_ action: OverflowAction) {
        guard let url = urlForAction(action) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /// Returns the URL for the given action
    private func urlForAction(_ action: OverflowAction) -> URL? {
        switch action {
        case .giveFeedback:
            return settings.giveFeedbackUrl.flatMap(URL.init)
        case .viewHistory:
            return settings.viewHistoryUrl.flatMap(URL.init)
        case .reportIssue:
            return settings.reportIssueUrl.flatMap(URL.init)
        }
    }
}

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

/// Individual message bubble in the transcript
struct TranscriptMessageBubble: View {
    let item: TranscriptItem
    let settings: WidgetSettings
    let customization: WidgetCustomization?

    private var colorResolver: ColorResolver {
        ColorResolver(customization: customization, settings: settings)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: item.timestamp)
    }

    private var bubbleBackground: Color {
        if item.isUser {
            return colorResolver.userBubbleBackground()
        } else {
            return colorResolver.agentBubbleBackground()
        }
    }

    private var bubbleTextColor: Color {
        if item.isUser {
            return colorResolver.userBubbleText()
        } else {
            return colorResolver.agentBubbleText()
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if item.isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: item.isUser ? .trailing : .leading, spacing: 8) {
                // Image attachments - iOS 13 compatible grid using HStack/VStack
                if !item.attachments.isEmpty {
                    ImageAttachmentsGrid(attachments: item.attachments)
                }

                // Text message
                if !item.text.isEmpty {
                    Text(item.text)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(bubbleBackground)
                        .foregroundColor(bubbleTextColor)
                        .cornerRadius(16, corners: item.isUser ?
                            [.topLeft, .topRight, .bottomLeft] :
                            [.topLeft, .topRight, .bottomRight])
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            if !item.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// iOS 13 compatible image grid
struct ImageAttachmentsGrid: View {
    let attachments: [ImageAttachment]

    private let columns = 2
    private let imageSize: CGFloat = 100
    private let spacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { columnIndex in
                        let index = rowIndex * columns + columnIndex
                        if index < attachments.count {
                            imageView(for: attachments[index])
                        }
                    }
                }
            }
        }
    }

    private var rowCount: Int {
        (attachments.count + columns - 1) / columns
    }

    private func imageView(for attachment: ImageAttachment) -> some View {
        DataURLImageView(dataURL: attachment.base64Data)
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Data URL Image View

struct DataURLImageView: View {
    let dataURL: String
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var hasError: Bool = false

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if isLoading {
                ZStack {
                    Color.gray.opacity(0.2)
                    ActivityIndicator(color: .gray)
                }
            } else if hasError {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            decodeDataURL()
        }
    }

    private func decodeDataURL() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: dataURL),
                  let data = url.dataRepresentation,
                  let decodedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasError = true
                }
                return
            }

            DispatchQueue.main.async {
                self.image = decodedImage
                self.isLoading = false
            }
        }
    }
}

// MARK: - URL Extension for Data URL

extension URL {
    var dataRepresentation: Data? {
        // Parse data URL format: data:image/jpeg;base64,<base64-string>
        guard scheme == "data" else { return nil }

        let urlString = absoluteString

        // Split by comma to get the base64 part
        guard let commaIndex = urlString.firstIndex(of: ",") else { return nil }
        let base64String = String(urlString[urlString.index(after: commaIndex)...])

        // Decode base64
        return Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
    }
}

// Helper for selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Overflow Menu Popup

/// Custom overflow menu popup matching Flutter widget design
struct OverflowMenuPopup: View {
    let actions: [OverflowAction]
    let colorResolver: ColorResolver
    let onActionSelected: (OverflowAction) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Transparent background to detect taps outside
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismiss()
                }

            // Menu popup
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    Button(action: {
                        onActionSelected(action)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: action.iconName)
                                .font(.system(size: 18))
                                .foregroundColor(colorResolver.primaryText())
                                .frame(width: 24, height: 24)

                            Text(action.title)
                                .font(.system(size: 16))
                                .foregroundColor(colorResolver.primaryText())

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(colorResolver.widgetSurface())
                    }

                    if index < actions.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(colorResolver.widgetSurface())
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            .frame(width: 240)
            .padding(.top, 60)
            .padding(.leading, 16)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    TranscriptView(
        settings: WidgetSettings(),
        customization: nil,
        transcriptItems: [
            TranscriptItem(id: "1", text: "Hello! How can I help you today?", isUser: false),
            TranscriptItem(id: "2", text: "I need help with my account", isUser: true),
            TranscriptItem(id: "3", text: "I'd be happy to help with your account. What specific issue are you experiencing?", isUser: false)
        ],
        userInput: "",
        isConnected: true,
        isMuted: false,
        agentStatus: .waiting,
        audioLevels: [0.3, 0.5, 0.7, 0.5, 0.3],
        onUserInputChange: { _ in },
        onSendMessage: {},
        onSendMessageWithImages: { _ in },
        onToggleMute: {},
        onEndCall: {},
        onCollapse: {},
        iconOnly: false
    )
}
