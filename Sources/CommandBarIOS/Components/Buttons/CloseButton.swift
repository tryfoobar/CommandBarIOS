import SwiftUI

struct CloseButton: View {
  let action: () -> Void

  var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .foregroundColor(.gray)
            
    
        }
        .buttonStyle(PlainButtonStyle())
  }
}


struct StarButton: View {
    @State var filled = false
  let action: () -> Void

  var body: some View {
        Button(action: action) {
            Image(systemName: filled ? "star.fill" : "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .foregroundColor(.gray)
            
    
        }
        .buttonStyle(PlainButtonStyle())
  }
}
