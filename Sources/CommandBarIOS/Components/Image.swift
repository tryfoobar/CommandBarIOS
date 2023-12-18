import SwiftUI

struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader

    let url: URL

    init(url: URL) {
        self.url = url
        self.loader = ImageLoader()
    }

    var body: some View {
        content.onAppear { loader.load(from: self.url) }
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Replace with whatever placeholder you want to use
                ActivityIndicator(isAnimating: .constant(true)).padding(.vertical)
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    func load(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
