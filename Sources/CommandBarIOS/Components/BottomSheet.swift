import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue = CGFloat(0)
    typealias Value = CGFloat
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
    }
}

struct BottomSheet<Content: View>: View {
    var onCloseAction: (() -> Void)?
    @Binding var showSheet: Bool
    var content: () -> Content

    @GestureState private var translation: CGFloat = 0
    @State private var offset: CGFloat = 0  // New State variable
    @State private var contentHeight : CGFloat = 0
    
    struct Handle: View {
        private let width: CGFloat = 60.0
        private let height: CGFloat = 5.0

        var body: some View {
            RoundedRectangle(cornerRadius: self.height / 2)
                .frame(width: self.width, height: self.height)
                .foregroundColor(Color.gray.opacity(0.3))
                .padding(10)
        }
    }

    
    var main: some View {
        Group {
            Rectangle()
                .fill(.white.opacity(0))
                .frame(width: UIScreen.main.bounds.width, height: 30)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 30)
                        .shadow(color: .black, radius: 25, y: 0)
                        .mask(Rectangle().gradientMask(
                            Gradient(colors: [.clear, .black])
                        )),
                    alignment: .top
                )
                .offset(y: 10)

            VStack {
                Handle()
                self.content()
            }
            .frame(width: UIScreen.main.bounds.width)
        }
    }
    var body: some View {
        ZStack {
            if showSheet {
                VStack(spacing: 0) {
                    
                    if #available(iOS 14.0, *) {
                        main.background(Color(UIColor.systemBackground).cornerRadius(16, corners: [.topLeft, .topRight]).ignoresSafeArea(.all, edges: .bottom))
                    } else {
                        main.background(Color(UIColor.systemBackground).cornerRadius(16, corners: [.topLeft, .topRight]).edgesIgnoringSafeArea(.bottom))
                    }
                    
                }
                .frame(width: UIScreen.main.bounds.width)
                .transition(.move(edge: .bottom))
                .offset(y: self.offset)
                .gesture(DragGesture()
                    .onChanged { value in
                        if value.startLocation.y < value.location.y {
                            self.offset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        let velocityThreshold: CGFloat = 1200.0
                        let swipeValid = self.offset > UIScreen.main.bounds.height * 0.25 || value.predictedEndTranslation.height > UIScreen.main.bounds.height * 0.25 || value.predictedEndLocation.y - value.startLocation.y > UIScreen.main.bounds.height * 0.25 || -value.predictedEndTranslation.height > velocityThreshold
                        
                        if swipeValid {
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.showSheet = false
                                onCloseAction?()
                            }
                        } else {
                            withAnimation(.spring()) {
                                self.offset = 0
                            }
                        }
                    }
                )
            }
        }.onAppear(perform: {
            DispatchQueue.main.async {
                withAnimation(.spring(duration: 0.3)) {
                    self.showSheet = true
                }
            }
        })
    }

}

struct RoundedTopRectangle: Shape {
    var cornerRadius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY)) // down
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // across
        path.addLine(to: CGPoint(x: rect.maxX, y: cornerRadius)) //up
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: true)
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: Extensions

extension View {
    func gradientMask(_ gradient: Gradient) -> some View {
        self.mask(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension CGSize {
    static func add(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
