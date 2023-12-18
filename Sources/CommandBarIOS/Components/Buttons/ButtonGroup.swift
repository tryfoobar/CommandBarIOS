import SwiftUI


// TODO: Move NPS functionality to later
enum ButtonGroupVariant {
    case primary
    case inclusive
}

struct ButtonGroupView<Option, Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    let variant: ButtonGroupVariant
    let options: [Option]
    let content: (Option, Bool) -> Content
    @Binding var selection: Int

    init(variant: ButtonGroupVariant = .primary, options: [Option], selection: Binding<Int>, @ViewBuilder content: @escaping (Option, Bool) -> Content) {
        self.variant = variant
        self.options = options
        self.content = content
        self._selection = selection
    }

    var body: some View {
        HStack {
            ForEach(options.indices, id: \.self) { index in
                let isSelected = variant == .inclusive ? index <= selection : index == selection
                Button(action: {
                    selection = index
                }) {
                    content(options[index], isSelected)
                }.frame(maxWidth: .infinity)
                
            }
        }
    }
}
