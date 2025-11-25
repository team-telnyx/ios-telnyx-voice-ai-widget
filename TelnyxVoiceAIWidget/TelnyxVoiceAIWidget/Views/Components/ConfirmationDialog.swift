//
//  ConfirmationDialog.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Custom confirmation dialog matching Flutter widget design
struct ConfirmationDialog: View {
    let title: String
    let message: String
    let colorResolver: ColorResolver
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onCancel()
                }

            // Dialog card
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(colorResolver.primaryText())
                    .fixedSize(horizontal: false, vertical: true)

                // Message
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(colorResolver.secondaryText())
                    .fixedSize(horizontal: false, vertical: true)

                // Buttons
                HStack(spacing: 12) {
                    Spacer()

                    // Close button
                    Button(action: onCancel) {
                        Text("Close")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorResolver.secondaryText())
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // OK button
                    Button(action: onConfirm) {
                        Text("OK")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorResolver.primaryText())
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(colorResolver.widgetSurface())
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .frame(maxWidth: 340)
            .padding(.horizontal, 32)
        }
    }
}
