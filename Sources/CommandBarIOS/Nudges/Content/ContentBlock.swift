import SwiftUI


struct ContentBlock: View {
    let formFactor: FormFactor
    let content: NudgeContentBlock
    let onAction: ((_ action: Action?) -> Void)?
    
    // TOOD: Annoying make better
    var fullWidthButton: Bool = false
    @Binding var surveyValue: Int
    @Binding var surveyTextValue: String
    
    @State private var contentHeight: CGFloat = .zero
    
    func isYouTubeURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return url.host?.contains("youtube") == true
    }
    
    
    func handleAction(meta: NudgeContentButtonBlockMeta) {
        if let conditional_actions = meta.conditional_actions {
            let condition = conditional_actions.first(where: { condition in
                if surveyValue == -1 {
                    return false
                }
                switch (condition.operator) {
                case .eq:
                    return surveyValue == condition.operand - 1
                case .neq:
                    return surveyValue != condition.operand - 1
                case .gt:
                    return surveyValue > condition.operand - 1
                case .lt:
                    return surveyValue < condition.operand - 1
                }
            })

            if (condition?.action != nil) {
                onAction?(condition?.action!)
            } else {
                onAction?(meta.action)
            }
        } else {
            onAction?(meta.action)
        }
    }
    var body: some View {
        VStack {
            switch content.meta {
                case .markdown(let meta):
                    HStack {
                        Text(LocalizedStringKey(meta.value ?? ""))
                        Spacer()
                    }
            
                case .surveyRating(let meta):
                    RatingBlock(ratingBlock: meta, currentRating: $surveyValue)
                case .button(let meta):
                    CMDButton(title: meta.label ?? "Button", variant: meta.button_type, fullWidth: fullWidthButton,  action: {
                        handleAction(meta: meta)
                    })
                case .image(let meta):
                    if let nonNilURLString = meta.src, let url = URL(string: nonNilURLString) {
                        AsyncImage(url: url)
                    } else {
                        EmptyView()
                    }
                case .video(let meta):
                    if let nonNilURLString = meta.src, let url = URL(string: nonNilURLString) {
                        
                        if (isYouTubeURL(nonNilURLString)) {
                            let strings = nonNilURLString.components(separatedBy: "/")
                            let videoId = strings.last ?? ""
                            YoutubeVideo(youtubeVideoID: videoId).scaledToFit()
                        } else {
                            AsyncVideo(url: url)
                        }
                        
                    } else {
                        EmptyView()
                    }
                case .surveyTextShort(let meta):
                    TextField(meta.prompt, text: $surveyTextValue)
                        .font(.system(size: 14))  // Set the font size to 16
                        .padding(.all, 8)
                        .background(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.gray.opacity(0.5), lineWidth: 1))
                case .surveyText(let meta):
                    if #available(iOS 14.0, *) {
                        TextEditor(text: $surveyTextValue)
                            .font(.system(size: 16))
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.gray.opacity(0.5), lineWidth: 1))
                            .frame(maxHeight: 150)
                    } else {
                        TextField(meta.prompt, text: $surveyTextValue)
                            .font(.system(size: 16))
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.gray.opacity(0.5), lineWidth: 1))
                            .frame(maxHeight: 150)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)

                    }
                default: EmptyView()
            }
        }.frame(maxWidth: fullWidthButton ? .infinity : nil)
    }
}
