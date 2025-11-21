//
//  TranscriptMessageBubble.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

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
        HStack(alignment: .top, spacing: 8) {
            if !item.isUser {
                // AI avatar (left side)
                avatarView
            } else {
                Spacer(minLength: 40)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(bubbleBackground)
                        .foregroundColor(bubbleTextColor)
                        .cornerRadius(20)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.horizontal, 4)
            }

            if item.isUser {
                // User avatar (right side)
                avatarView
            } else {
                Spacer(minLength: 40)
            }
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if item.isUser {
            // User icon - circular with person symbol
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        } else {
            // AI avatar - square image or default user icon
            if let logoUrlString = settings.logoIconUrl,
               !logoUrlString.isEmpty,
               let logoUrl = URL(string: logoUrlString) {
                RemoteImageView(
                    url: logoUrl,
                    placeholder: Image(systemName: "person.fill"),
                    width: 32,
                    height: 32
                )
                .cornerRadius(6)
            } else {
                // Default icon if no logo
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
