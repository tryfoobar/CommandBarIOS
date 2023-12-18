import SwiftUI


struct StarButtons: View {
    @Binding var selection: Int;
    
    let action: () -> Void;
    let count: Int

    let starColor: Color = Color(.sRGB, red: 66/255, green: 66/255, blue: 77/255, opacity: 0.24)
    let activeStarColor: Color = Color(.sRGB, red: 221/255, green: 158/255, blue: 35/255, opacity: 1)
    let borderColor: Color = Color(.sRGB, red: 10/255, green: 10/255, blue: 15/255, opacity: 0.24)
    let backgroundColor: Color = Color.white
    let activeBorderColor: Color = Color(.sRGB, red: 255/255, green: 180/255, blue: 34/255)
    let activeBackgroundColor: Color = Color(.sRGB, red: 255/255, green: 242/255, blue: 217/255)
    
    var body: some View {
        let stars = Array(repeating: "", count: count)
        
        ButtonGroupView(variant: .inclusive, options: stars, selection: $selection) { option, isSelected in
            ZStack {
                Image(systemName: "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? activeStarColor.darker(by: 20) : starColor)
                    .opacity(isSelected ? 1 : 0)
                Image(systemName: isSelected ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSelected ? 20 : 24, height: isSelected ? 20 : 24) // Original size
                    .foregroundColor(isSelected ? activeStarColor : starColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? activeBackgroundColor : backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? activeBorderColor : borderColor, lineWidth: 1)
            )
        }
    }
}

struct EmojiButtons: View {
    @Binding var selection: Int;
    
    let action: () -> Void;
    let emojis: [String]
    
    let borderColor: Color = Color(.sRGB, red: 10/255, green: 10/255, blue: 15/255, opacity: 0.24)
    let backgroundColor: Color = Color.white
    let activeBorderColor: Color = Color(.sRGB, red: 255/255, green: 180/255, blue: 34/255)
    let activeBackgroundColor: Color = Color(.sRGB, red: 255/255, green: 242/255, blue: 217/255)
    

    var body: some View {
        ButtonGroupView(options: emojis, selection: $selection) { option, isSelected in
            Text(option)
                .shadow(color: .init(.sRGB, red: 0, green: 0, blue: 0, opacity: isSelected ? 0.35 : 0), radius: 7, x: 0, y: 4)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? activeBackgroundColor : backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? activeBorderColor : borderColor, lineWidth: 1)
                )
        }
    }
}

struct NumberButtons: View {
    @Binding var selection: Int;
    
    let action: () -> Void;
    let count: Int

    let borderColor: Color = Color(.sRGB, red: 10/255, green: 10/255, blue: 15/255, opacity: 0.24)
    let backgroundColor: Color = Color.white
    let activeBorderColor: Color = Color(.sRGB, red: 255/255, green: 180/255, blue: 34/255)
    let activeBackgroundColor: Color = Color(.sRGB, red: 255/255, green: 242/255, blue: 217/255)
    
    var body: some View {
        let numbers = Array(0...count).map { String($0) }
        
        ButtonGroupView(options: numbers, selection: $selection) { option, isSelected in
            Text(option)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? activeBackgroundColor : backgroundColor)
                .foregroundColor(.black)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? activeBorderColor : borderColor, lineWidth: 1)
                )
        }
    }
}

struct RatingBlock: View {
    let ratingBlock: NudgeContentSurveyRatingBlockMeta

    @Binding var currentRating: Int
    
    var labelColor: Color {
        Color(red: 162.0 / 255, green: 162.0 / 255, blue: 169.0 / 255, opacity: 1)
    }
    
    var RatingLabels: some View {
        HStack {
            Text(ratingBlock.lower_label ?? "Awful")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .lineSpacing(15)
                .foregroundColor(labelColor)
            Spacer()
            Text(ratingBlock.upper_label ?? "Amazing")
                .fontWeight(.medium)
                .font(.system(size: 12))
                .lineSpacing(15)
                .foregroundColor(labelColor)
            
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Group {
                    switch ratingBlock.type {
                    case "stars":
                        StarButtons(selection: $currentRating, action: { print("Rating!") }, count: ratingBlock.options ?? 0)
                    case "emojis":
                        if ratingBlock.emojis == nil {
                            EmptyView()
                        } else {
                            EmojiButtons(selection: $currentRating, action: { print("emojis") }, emojis: ratingBlock.emojis ?? ["🙁", "🙂", "🤩"])
                        }
                    case "numbers":
                        NumberButtons(selection: $currentRating, action: { print("numbers")}, count: ratingBlock.options ?? 0)
                        
                    default:
                        EmptyView()
                        
                    }
                }
            }
            .flexibleFrame(width: ratingBlock.type != "emojis" ? 40 : nil)
            .frame(alignment: .leading)
            
            if (ratingBlock.upper_label != nil || ratingBlock.lower_label != nil) {
                RatingLabels
            }
        }
    }
}

struct RatingButtonStyle: ButtonStyle {
    let selectedMarked: Bool
    let type: String

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .frame(width: type != "emojis" ? 40 : nil)
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring())
            .buttonStyle(PlainButtonStyle())
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension View {
    @ViewBuilder
    func flexibleFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        if let width = width, let height = height {
            self.frame(width: width, height: height)
        } else if let width = width {
            self.frame(minWidth: width, maxWidth: .infinity)
        } else if let height = height {
            self.frame(minHeight: height, maxHeight: .infinity)
        } else {
            self
        }
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
