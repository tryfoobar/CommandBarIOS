import Foundation
import SwiftUI

extension Color {
    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    
    static func random() -> Color {
        let red = Double.random(in: 0..<1)
        let green = Double.random(in: 0..<1)
        let blue = Double.random(in: 0..<1)
        return Color(red: red, green: green, blue: blue)
    }
    
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.components.red),
                  green: Double(uiColor.components.green),
                  blue: Double(uiColor.components.blue),
                  opacity: Double(uiColor.components.alpha))
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        if let uiColor = self.uiColor().lighter(by: percentage) {
            return Color(uiColor: uiColor)
        }
        return self
        
    }

    func darker(by percentage: CGFloat = 30.0) -> Color {
        if let uiColor = self.uiColor().darker(by: percentage) {
            return Color(uiColor: uiColor)
        }
        return self
        
    }

    func adjust(by percentage: CGFloat = 30.0) -> Color {
        let components = self.components()
        return Color(red: min(Double(components.r + percentage/100), 1.0),
                     green: min(Double(components.g + percentage/100), 1.0),
                     blue: min(Double(components.b + percentage/100), 1.0),
                     opacity: Double(components.a))
    }
}


extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
