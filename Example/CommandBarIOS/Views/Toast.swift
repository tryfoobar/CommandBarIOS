import SwiftUI

struct Toast: View {
    var message: String
    
    @State private var animationScale: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                Text(message)
            }
            .foregroundColor(.white)
            .padding(10)
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .scaleEffect(animationScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 1))
            .onAppear {
                animationScale = 1
            }
        }
    }
}
