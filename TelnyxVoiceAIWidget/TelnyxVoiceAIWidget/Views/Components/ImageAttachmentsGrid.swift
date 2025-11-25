//
//  ImageAttachmentsGrid.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// iOS 13 compatible image grid
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
