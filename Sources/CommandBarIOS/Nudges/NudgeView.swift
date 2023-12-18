import SwiftUI

struct NudgeView: View {
    let nudge: Nudge
    let step: NudgeStep
    let stepIndex: Int

    @State private var confettiEnabled: Int = 0
    @State private var cumulativeDrag: CGFloat = 0

    @State private var appear = 0
    @State private var isSheetPresented = true
    
    @State private var viewOffset: CGSize = .zero
    @GestureState private var translation: CGSize = .zero
    @State public var surveyValue: Int = -1
    @State public var surveyTextValue: String = ""
    
    
    @State private var height: CGFloat = 0
    
    var onCloseAction: (() -> Void)?
    // TODO: Cleanup to make accessing these things easier
    var onAction: ((_ action: Action, _ nudge: Nudge, _ step: NudgeStep, _ surveyValue: Int, _ surveyTextValue: String) -> Void)?

    var width: CGFloat = 300
    var cornerRadius: CGFloat = 15
    var shadowRadius: CGFloat = 5
    var shadowOffsetX: CGFloat = 0
    var shadowOffsetY: CGFloat = 0
    var padding: CGFloat = 16
        
    
    func handleCloseAction() {
        self.appear = 0
        onCloseAction?()
    }
    
    func handleAction(action: Action?) {
        guard let action = action else { return }
        
        self.onAction?(action, nudge, step, surveyValue, surveyTextValue)
    }
            
    var HeaderStack: some View {
        HStack {
            Text(step.title).font(.headline)
            Spacer()
            if (nudge.dismissible && step.form_factor.type != .clip) {
                CloseButton(action: handleCloseAction)
            }
                
        }
    }
    
    var ContentStack: some View {
        let nonButtons = step.content.filter { $0.type != .button }
        let buttonBlocks = step.content.filter({ $0.type == .button }).sorted { (lhs: NudgeContentBlock, rhs: NudgeContentBlock) -> Bool in
            switch(lhs.type, rhs.type) {
            case (.button, .button):
                // Move primary buttons after secondary ones
                if case let .button(lhsButtonMeta) = lhs.meta, case let .button(rhsButtonMeta) = rhs.meta {
                    switch (lhsButtonMeta.button_type, rhsButtonMeta.button_type) {
                    case (.primary, .primary), (.secondary, .secondary), (.none, .none):
                        return false
                    case (.primary, .secondary), (.primary, .none), (.none, .secondary):
                        return false
                    case (.secondary, .primary), (.secondary, .none), (.none, .primary):
                        return true
                    default:
                        return true
                    }
                }
            case (.button, _): return false
            case (_, .button): return true
            default: return false
            }
            
            return false
        }
        
        return VStack {
            // TODO: Make content block conform to Identifiable and Equatable
            ForEach(Array(nonButtons.indices), id: \.self) { index in
                ContentBlock(formFactor: step.form_factor, content: nonButtons[index], onAction: nil, surveyValue: $surveyValue, surveyTextValue: $surveyTextValue)
            }
            
            HStack {
                if nudge.show_step_counter && nudge.steps.count > 1 {
                    Text("\(self.stepIndex + 1)/\(nudge.steps.count)").foregroundColor(.init(red: 110/255, green: 110/255, blue: 110/255))
                    Spacer()
                    ForEach(Array(buttonBlocks.indices), id: \.self) { index in
                        ContentBlock(formFactor: step.form_factor, content: buttonBlocks[index], onAction: handleAction, surveyValue: $surveyValue, surveyTextValue: $surveyTextValue)
                    }
                } else {
                    ForEach(Array(buttonBlocks.indices), id: \.self) { index in
                        ContentBlock(formFactor: step.form_factor, content: buttonBlocks[index], onAction: handleAction, fullWidthButton: true, surveyValue: $surveyValue, surveyTextValue: $surveyTextValue)
                    }
                }
            }
        }
    }
    
    
    var Content: some View {
        Group {
            if step.form_factor.type == .clip {
                VStack (alignment: .leading, spacing: 10) {
                    HeaderStack
                    ContentStack
                }
                .padding(.horizontal)
            } else {
                VStack (alignment: .leading, spacing: 10) {
                    HeaderStack
                    ContentStack
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(cornerRadius)
                .scaleEffect(self.appear == 1 ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                        self.appear = 1
                    }
                }
                .padding()
            }
        }
    }
    
    var Modal: some View {
        Content
    }
    
    var Pin: some View {
        Content
    }
    
    var Popover: some View {
        GeometryReader { geometry in
            Content
                .shadow(color: Color(red: 10/255, green: 10/255, blue: 15/255, opacity: 0.24), radius: 20, x: 0, y: 16)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.size.height)
                })
                .offset(y: viewOffset.height + translation.height)
                .gesture(enableDragGesture(geometry: geometry))
                .onPreferenceChange(ViewHeightKey.self) { height in
                     self.height = height
                 }
        }
    }
    
    var body: some View {
        VStack {
            self.renderFormFactor(for: self.step.form_factor.type)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: getAlignment(for: self.step.form_factor.type))
    }
    
    var Clip: some View {
        BottomSheet(onCloseAction: onCloseAction, showSheet: $isSheetPresented) {
            Content
        }
    }
    
    func renderFormFactor(for type: FormFactorType) -> some View {
        Group {
            switch (type) {
            case .modal:
                Modal
            case .popover:
                Popover
            case .pin:
                Pin
            case .clip:
                Clip
            }
            
        }
    }
    
    
    func getAlignment(for type: FormFactorType) -> Alignment {
        switch (step.form_factor.type) {
        case .modal:
            return .center
        case .popover:
            switch (step.form_factor.position) {
            case .bottomLeft, .bottomRight:
                return .bottom
            case .topRight, .topLeft:
                return .top
            default:
                return .center
            }
        case .clip:
            return .bottom
        case .pin:
            return .center
        }
    }

    
    func enableDragGesture(geometry: GeometryProxy) -> some Gesture {
            DragGesture()
                .onChanged { value in
                    self.viewOffset.height = value.translation.height + self.cumulativeDrag
                }
                .onEnded { value in
                    DispatchQueue.main.async {
                        let screenSize = geometry.size.height
                        let popoverHeight = self.height
                        let totalDragged = self.viewOffset.height
                        let top: CGFloat = 0
                        let centerTop: CGFloat = screenSize / 3
                        let centerBottom: CGFloat = (screenSize / 3) * 2
                        let bottom: CGFloat = screenSize
                        let sizes = [top, centerTop, centerBottom, bottom]
                        let draggingUpwards = value.predictedEndLocation.y < value.startLocation.y

                        var newOffset: CGSize = CGSize(width: 0, height: 0)

                        if draggingUpwards {
                            let options = sizes.filter { $0 <= totalDragged }
                            let closest = options.max() ?? top
                            newOffset = CGSize(width: 0, height: closest)
                        } else {
                            let options = sizes.filter { $0 >= totalDragged }
                            let closest = options.min() ?? bottom
                            newOffset = CGSize(width: 0, height: closest - popoverHeight)
                        }

                        withAnimation(.spring()) {
                            self.viewOffset = newOffset
                            self.cumulativeDrag = newOffset.height
                        }
                    }

                }
        }
}
