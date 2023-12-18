import SwiftUI

struct CMDButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var variant: NudgeContentButtonBlockMeta.ButtonType?
    var fullWidth: Bool = false
    var action: (() -> Void)?
    
    var backgroundColor: Color {
        return  (variant  ?? .primary) == .primary ? colorScheme == .dark ? Color(UIColor.systemBackground.lighter(by: 15)!) : Color.black : Color.white
    }
  
    var foregroundColor: Color {
        return  (variant  ?? .primary) == .primary ? Color.white : Color.black
    }
  
    var borderColor: Color {
        return (variant  ?? .primary) == .primary ? colorScheme == .dark ? Color(UIColor.systemBackground.lighter(by: 15)!) : Color.black : Color.gray.opacity(0.5)
    }

    var body: some View {
        Button(action: action ?? { print("not implemented")}) {
            Text(title)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
                .font(.system(size: 14, weight: .semibold))
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(borderColor, lineWidth: 1) )
                .cornerRadius(5)
        }
    }
}
