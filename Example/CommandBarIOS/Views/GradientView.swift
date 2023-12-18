import SwiftUI
import UIKit

struct GradientView: View {
    
    @State private var stage: Double = 0
    private let maxStages: Double = 10.0
    
    private let startColor: Color = .purple
    private let endColor: Color = .blue.darker(by: 2)

    private let timer = Timer.publish(every: 0.1, on: .main, in: .commonModes).autoconnect() // adjust as needed

    var body: some View {
        ZStack {
            ForEach(0..<(Int(maxStages)), id: \.self) { i in
                gradient(for: i)
                    .opacity(opacity(for: i))
                    .animation(.linear(duration: 0.4), value: self.stage)
                    
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    self.stage = (self.stage + 1)
                }
            }
        }
    }
    
    private func gradient(for index: Int) -> LinearGradient {
        let points = gradientPoints(for: index)
        return LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: points.0,
            endPoint: points.1
        )
    }
    
    private func gradientPoints(for index: Int) -> (UnitPoint, UnitPoint) {
        switch index {
        case 0:
            return (.topLeading, .bottomTrailing)
        case 1:
            return (.top, .bottom)
        case 2:
            return (.topTrailing, .bottomLeading)
        case 3:
            return (.trailing, .leading)
        case 4:
            return (.bottomTrailing, .topLeading)
        case 5:
            return (.bottom, .top)
        case 6:
            return (.bottomLeading, .topTrailing)
        case 7:
            return (.leading, .trailing)
        case 8:
            return (.topLeading, .bottomTrailing)
        default:
            return (.topLeading, .bottomTrailing)
        }
    }
    
    private func opacity(for index: Int) -> Double {
        let adjustedStage = (self.stage - Double(index)) / self.maxStages
        return max(0, 0.5 * cos(2 * Double.pi * adjustedStage) + 0.5)
    }
}


struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
