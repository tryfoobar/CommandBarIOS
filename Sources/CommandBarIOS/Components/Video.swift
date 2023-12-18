import SwiftUI
import AVKit
import Combine
import WebKit

struct YoutubeVideo: UIViewRepresentable {
    
    var youtubeVideoID: String
    
    func makeUIView(context: Context) -> WKWebView  {
        
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        let path = "https://www.youtube.com/embed/\(youtubeVideoID)"
        guard let url = URL(string: path) else { return }
        
        uiView.scrollView.isScrollEnabled = false
        uiView.load(.init(url: url))
    }
}

struct AsyncVideo: View {
    let url: URL
    

    var body: some View {
        VideoPlayerView(url: url)
    }
}
struct VideoPlayerView: View {
    
    @ObservedObject var videoLoader: VideoLoader
    @State private var player: AVPlayer?

    init(url: URL) {
        videoLoader = VideoLoader(url: url)
    }

    var body: some View {
        ZStack {
            if videoLoader.loading {
                ActivityIndicator(isAnimating: .constant(true))
            } else {
                if #available(iOS 14.0, *) {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fit)
                        .onAppear {
                            self.player = AVPlayer(url: videoLoader.url)
                            self.player?.play()
                        }
                } else {
                    AVVideoPlayerView(url: videoLoader.url)
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

struct AVVideoPlayerView: UIViewControllerRepresentable {
    var url: URL

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<AVVideoPlayerView>) {
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        player.play()
        return controller
    }
}



class VideoLoader: ObservableObject {
    
    @Published var loading: Bool
    var url: URL

    init(url: URL) {
        self.url = url
        self.loading = true
        loadVideo()
    }
    
    func loadVideo() {
        let asset = AVAsset(url: self.url)
        let playableKey = "playable"
    
        asset.loadValuesAsynchronously(forKeys: [playableKey]) { [weak self] in
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: playableKey, error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async {
                    self?.loading = false
                }
            case .failed, .cancelled:
                print("Failed to load URL: \(error?.localizedDescription ?? "Unknown error")")
            default:
                break
            }
        }
    }
}
