//
//  LogoView.swift
//  CommandBarIOS_Example
//

import SwiftUI
import UIKit

private let logoURL = URL(
    string: "https://www.freelogovectors.net/wp-content/uploads/2023/11/amplitude_logo-freelogovectors.net_.png"
)!

struct LogoView: View {
    var body: some View {
        ZStack {
            // White disc sitting behind the logo so the transparent area inside
            // the "A" reads as white instead of letting the gradient show through.
            // The drop shadow attaches to this disc (rather than to the whole
            // composite) so the shadow is a clean circular halo instead of
            // tracing the irregular silhouette of the logo.
            Circle()
                .fill(Color.white)
                .frame(width: 68, height: 68)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

            RemoteImage(url: logoURL)
                .frame(width: 100, height: 100)
        }
        .frame(width: 100, height: 100)
    }
}

/// Lightweight URLSession-backed `AsyncImage` substitute so the example builds on iOS 14+.
struct RemoteImage: View {
    let url: URL

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard image == nil else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
