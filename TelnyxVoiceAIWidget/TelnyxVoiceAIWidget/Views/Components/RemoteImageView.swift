//
//  RemoteImageView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Custom image loader compatible with iOS 13+
struct RemoteImageView: View {
    let url: URL
    let placeholder: Image
    let width: CGFloat
    let height: CGFloat

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            } else {
                placeholder
                    .resizable()
                    .frame(width: width, height: height)
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let loadedImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = loadedImage
                self.isLoading = false
            }
        }.resume()
    }
}