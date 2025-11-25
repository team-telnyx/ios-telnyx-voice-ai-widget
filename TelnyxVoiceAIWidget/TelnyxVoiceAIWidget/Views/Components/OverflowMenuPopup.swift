//
//  OverflowMenuPopup.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

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

/// Custom overflow menu popup matching Flutter widget design
struct OverflowMenuPopup: View {
    let actions: [OverflowAction]
    let colorResolver: ColorResolver
    let onActionSelected: (OverflowAction) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Semi-transparent background to detect taps outside and provide overlay
            Color.black.opacity(0.001)
                .edgesIgnoringSafeArea(.all)
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
    }
}
