//
//  DataURLImageView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI
import UIKit

/// View that displays an image from a data URL
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
