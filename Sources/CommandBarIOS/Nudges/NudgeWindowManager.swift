import SwiftUI
import UIKit

// MARK: Window
class NudgeWindow: UIWindow {
    var nudge: Nudge
    
    init(nudge: Nudge, frame: CGRect) {
        self.nudge = nudge

        super.init(frame: frame)
    }
    
    init(nudge: Nudge, windowScene: UIWindowScene) {
        self.nudge = nudge
        super.init(windowScene: windowScene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        // Do not return self or the root view if you want to ignore touches on them
        if hitView == self || hitView == self.rootViewController?.view {
            return nil
        }

        return hitView
    }
}

// MARK: Window Manager
class NudgeWindowManager {
    static let shared: NudgeWindowManager = NudgeWindowManager()
    
    weak var internalSDKDelegate: CommandBarInternalSDKDelegate?
    private var nudgeWindow: NudgeWindow?

    private var currentNudgeView: NudgeView? = nil
    private var currentStepIndex = 0
    
    func renderNudge(_ nudge: Nudge) {
        if !nudge.is_live || nudge.archived { return }
        
        self.showNudge(nudge)
    }
    
    private func handleAction(_ action: Action, _ nudge: Nudge, _ step: NudgeStep, _ surveyValue: Int, _ surveyTextValue: String) {
        NudgeWindowManager.shared.trackSurveyEvent(nudge, step, surveyValue, surveyTextValue)

        DispatchQueue.main.async {
            switch(action) {
            case .link(let linkAction):
                // let operation = linkAction.operation ?? .blank
                let value = linkAction.value
                
                if let url = URL(string: value) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .nudge(let nudgeAction):
                NudgeWindowManager.shared.hideNudge()
                if let nudge = CommandBarInternalSDK.shared.config?.nudges_v2.first(where: {
                    if let id = Int( $0.id) {
                        return id == nudgeAction.value
                    }
                    return false
                }) {
                    self.currentStepIndex = 0
                    NudgeWindowManager.shared.showNudge(nudge)
                } else { return }
            case .stepBack(_):
                NudgeWindowManager.shared.goToNudgeStep(nudge, step: self.currentStepIndex - 1)
            case .openChat(let openChatAction):
                NudgeWindowManager.shared.internalSDKDelegate?.didTriggerOpenChat(withType: openChatAction.meta.type)
            case .dismiss(_):
                NudgeWindowManager.shared.hideNudge()
            case .goToNudgeStep(let nudgeStepAction):
                NudgeWindowManager.shared.goToNudgeStep(nudge, step: nudgeStepAction.value)
            case .none(_):
                NudgeWindowManager.shared.goToNudgeStep(nudge, step: self.currentStepIndex + 1)
            case .click(_):
                print("Unsupported")
            default:
                NudgeWindowManager.shared.goToNudgeStep(nudge, step: self.currentStepIndex + 1)
            }
        }
    }
    
    private func trackSurveyEvent(_ nudge: Nudge, _ step: NudgeStep, _ surveyValue: Int, _ surveyTextValue: String) {
        if let surveyContent = step.content.first(where: { return $0.type == .surveyRating || $0.type == .surveyText || $0.type == .surveyTextShort }) {
            let nudgeStepEvent = NudgeEvent.NudgeStepEvent(id: String(step.id), title: step.title)
            let nudgeEvent = NudgeEvent(id: nudge.id, trigger: nudge.trigger, template_source: nudge.template_source, slug: nudge.slug, step: nudgeStepEvent, status: .init(is_preview: false, is_live: true))
            
            switch(surveyContent.meta) {
            case .surveyRating(let meta):
                switch(meta.type) {
                case "emojis":
                    if let emojis = meta.emojis {
                        let emoji = emojis[surveyValue]
                        let responseEvent = NumberResponseEvent(value: surveyValue, max: meta.options ?? 0, emoji: emoji)
                        let attrs = EventAttributes(type: .log, response: .number(responseEvent), nudge: nudgeEvent)
                        Analytics.shared.log(eventName: .surveyResponse, data: attrs)
                    }
                case "stars", "numbers":
                    let responseEvent = NumberResponseEvent(value: surveyValue, max: meta.options ?? 0)
                    let attrs = EventAttributes(type: .log, response: .number(responseEvent), nudge: nudgeEvent)
                    Analytics.shared.log(eventName: .surveyResponse, data: attrs)
                default:
                    return
                }
                
            case .surveyText(_), .surveyTextShort(_):
                let responseEvent = StringResponseEvent(value: surveyTextValue)
                let attrs = EventAttributes(type: .log, response: .string(responseEvent), nudge: nudgeEvent)
                Analytics.shared.log(eventName: .surveyResponse, data: attrs)
            default:
                return
            }
        }
    }
    
    private func goToNudgeStep(_ nudge: Nudge, step: Int) {
        DispatchQueue.main.async {
            NudgeWindowManager.shared.hideNudge()
            NudgeWindowManager.shared.currentStepIndex = step
            NudgeWindowManager.shared.showNudge(nudge)
        }
        
    }
    
    private func showNudge(_ nudge: Nudge) {
        guard nudgeWindow == nil else { return }
        guard NudgeWindowManager.shared.currentStepIndex < nudge.steps.count else {
            NudgeWindowManager.shared.hideNudge()
            NudgeWindowManager.shared.currentStepIndex = 0
            return
        }
        
        let currentStep = nudge.steps[NudgeWindowManager.shared.currentStepIndex]
        
        NudgeWindowManager.shared.currentNudgeView = NudgeView(
            nudge: nudge,
            step: currentStep,
            stepIndex: NudgeWindowManager.shared.currentStepIndex,
            onCloseAction: {
                DispatchQueue.main.async {
                    NudgeWindowManager.shared.hideNudge()
                }
            },
            onAction: handleAction
        )
        
        // Try and get an active scene, fall back to the screens frame
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene?
        if (windowScene != nil) {
            nudgeWindow = NudgeWindow(nudge: nudge, windowScene: windowScene!!)
        } else {
            nudgeWindow = NudgeWindow(nudge: nudge, frame: UIScreen.main.bounds)
        }
        
        let hostingController = UIHostingController(rootView: NudgeWindowManager.shared.currentNudgeView)

        hostingController.view.backgroundColor = .clear
        
        
        if currentStep.form_factor.type == .modal {
            nudgeWindow?.backgroundColor = .black.withAlphaComponent(0.5)
        }
        
        
        nudgeWindow!.windowLevel = .alert
        nudgeWindow!.rootViewController = hostingController
        nudgeWindow!.makeKeyAndVisible()
    }
    
    private func hideNudge() {
        NudgeWindowManager.shared.currentStepIndex = 0
        if (nudgeWindow?.rootViewController) != nil {
            NudgeWindowManager.shared.nudgeWindow = nil
            NudgeWindowManager.shared.currentNudgeView = nil
        }
    }

}




