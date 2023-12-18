struct AdminAction: Codable {
    var type: String = "admin"
    var value: String
}

struct CallbackAction: Codable {
    var type: String = "callback"
    var value: String
}

struct OpenBarAction: Codable {
    var type: String = "open_bar"
    var value: String?
    var categoryFilter: Int?
}

enum LinkActionOperation: String, Codable {
    case router = "router"
    case same = "self"
    case blank = "blank"
}

struct LinkAction: Codable {
    var type: String = "link"
    var value: String
    var operation: LinkActionOperation?
}

struct OpenChatAction: Codable {
    var type: String = "open_chat"
    var meta: Meta

    struct Meta: Codable {
        var type: String
    }
}

struct DismissAction: Codable {
    var type: String = "dismiss"
}

struct StepBackAction: Codable {
    var type: String = "step_back"
}

struct SnoozeAction: Codable {
    var type: String = "snooze"
}

struct ClickAction: Codable {
    var type: String = "click"
    var value: String
}


struct BuiltInAction: Codable {
    var type: String = "builtin"
    var value: String
}

struct WebhookAction: Codable {
    var type: String = "webhook"
    var value: String
}

struct AppcuesAction: Codable {
    var type: String = "appcues"
    var value: String
}

struct ScriptAction: Codable {
    var type: String = "script"
    var value: String
}

struct VideoAction: Codable {
    var type: String = "video"
    var value: String
}

enum HelpDocActionOperation: String, Codable {
    case router = "router"
    case same = "self"
    case blank = "blank"
    case help_hub = "help_hub"
}

struct HelpDocAction: Codable {
    var type: String = "helpdoc"
    var value: String
    var operation: HelpDocActionOperation?
    var doc_metadata: DocMetadata?

    struct DocMetadata: Codable {
        var content_type: String?
        var date: String?
    }
}

struct CommandAction: Codable {
    var type: String = "execute_command"
    var meta: Meta

    struct Meta: Codable {
        var type: String
        var command: String
    }
}

struct NoAction: Codable {
    var type: String = "no_action"
}

struct NudgeAction: Codable {
    var type: String = "nudge"
    var value: Int
}

struct GoToNudgeStepAction: Codable {
    var type: String = "go_to_step"
    var value: Int
}

struct QuestlistAction: Codable {
    var type: String = "questlist"
    var value: Int
}

enum Action: Codable {
    case command(CommandAction)
    case none(NoAction)
    case click(ClickAction)
    case link(LinkAction)
    case openChat(OpenChatAction)
    case dismiss(DismissAction)
    case snooze(SnoozeAction)
    case questlist(QuestlistAction)
    case nudge(NudgeAction)
    case goToNudgeStep(GoToNudgeStepAction)
    case stepBack(StepBackAction)
    case openBar(OpenBarAction)
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    enum ActionTypes: String, Codable {
        case command = "command"
        case none = "no_action"
        case click = "click"
        case link = "link"
        case openChat = "open_chat"
        case dismiss = "dismiss"
        case snooze = "snooze"
        case questlist = "questlist"
        case nudge = "nudge"
        case goToNudgeStep = "go_to_step"
        case stepBack = "step_back"
        case openBar = "open_bar"
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(ActionTypes.self, forKey: .type)

            switch type {
                case .command:
                    let commandAction = try CommandAction(from: decoder)
                    self = .command(commandAction)
                case .none:
                    let noAction = try NoAction(from: decoder)
                    self = .none(noAction)
                case .click:
                    let clickAction = try ClickAction(from: decoder)
                    self = .click(clickAction)
                case .link:
                    let linkAction = try LinkAction(from: decoder)
                    self = .link(linkAction)
                case .openChat:
                    let openChatAction =  try OpenChatAction(from: decoder)
                    self = .openChat(openChatAction)
                case .dismiss:
                    let dismissAction = try DismissAction(from: decoder)
                    self = .dismiss(dismissAction)
                case .snooze:
                    let snoozeAction = try SnoozeAction(from: decoder)
                    self = .snooze(snoozeAction)
                case .questlist:
                    let questlistAction = try QuestlistAction(from: decoder)
                    self = .questlist(questlistAction)
                case .nudge:
                    let nudgeAction = try NudgeAction(from: decoder)
                    self = .nudge(nudgeAction)
                case .goToNudgeStep:
                    let goToNudgeStepAction = try GoToNudgeStepAction(from: decoder)
                    self = .goToNudgeStep(goToNudgeStepAction)
                case .stepBack:
                    let stepBackAction = try StepBackAction(from: decoder)
                    self = .stepBack(stepBackAction)
                case .openBar:
                    let openBarAction = try OpenBarAction(from: decoder)
                    self = .openBar(openBarAction)
                default:
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid type"))
        
            }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .command(let command):
            try container.encode(ActionTypes.command.rawValue, forKey: .type)
            try command.encode(to: encoder)
        case .none(let none):
            try container.encode(ActionTypes.none.rawValue, forKey: .type)
            try none.encode(to: encoder)
        case .click(let click):
            try container.encode(ActionTypes.click.rawValue, forKey: .type)
            try click.encode(to: encoder)
        case .link(let link):
            try container.encode(ActionTypes.link.rawValue, forKey: .type)
            try link.encode(to: encoder)
        case .openChat(let openChat):
            try container.encode(ActionTypes.openChat.rawValue, forKey: .type)
            try openChat.encode(to: encoder)
        case .dismiss(let dismiss):
            try container.encode(ActionTypes.dismiss.rawValue, forKey: .type)
            try dismiss.encode(to: encoder)
        case .snooze(let snooze):
            try container.encode(ActionTypes.snooze.rawValue, forKey: .type)
            try snooze.encode(to: encoder)
        case .questlist(let questlist):
            try container.encode(ActionTypes.questlist.rawValue, forKey: .type)
            try questlist.encode(to: encoder)
        case .nudge(let nudge):
            try container.encode(ActionTypes.nudge.rawValue, forKey: .type)
            try nudge.encode(to: encoder)
        case .goToNudgeStep(let goToNudgeStep):
            try container.encode(ActionTypes.goToNudgeStep.rawValue, forKey: .type)
            try goToNudgeStep.encode(to: encoder)
        case .stepBack(let stepBack):
            try container.encode(ActionTypes.stepBack.rawValue, forKey: .type)
            try stepBack.encode(to: encoder)
        case .openBar(let openBar):
            try container.encode(ActionTypes.openBar.rawValue, forKey: .type)
            try openBar.encode(to: encoder)
        }
    }

}

struct LabeledAction: Codable {
    var cta: String;
    var action: Action
}


enum FrequencyLimit: String, Codable {
    case no_limit = "no_limit"
    case once_per_session = "once_per_session"
    case once_per_user = "once_per_user"
    case untilInteraction = "until_interaction"
}
//
//protocol PushTrigger: Codable {
//    var type: String { get set }
//}
//
//struct WhenConditionsPass: PushTrigger {
//    var type: String = "when_conditions_pass"
//}
//
//struct WhenPageReached: PushTrigger {
//    var type: String = "when_page_reached"
//    var url: String
//}
//
//struct OnCommandExecution: PushTrigger {
//    var type: String = "on_command_execution"
//    var command: String
//}
//
//struct OnEvent: PushTrigger {
//    var type: String = "on_event"
//    var event: String
//}
//
//struct WhenElementAppears: PushTrigger {
//    var type: String = "when_element_appears"
//    var selector: String
//}
//
//struct OnUserConfusion: PushTrigger {
//    var type: String = "on_user_confusion"
//}
//
//struct OnRageClick: PushTrigger {
//    var type: String = "on_rage_click"
//}
//
//struct SmartDelay: PushTrigger {
//    var type: String = "smart_delay"
//}
//
//struct WhenShareLinkViewed: PushTrigger {
//    var type: String = "when_share_link_viewed"
//}

enum PushTrigger: Codable, Equatable {
    
    enum CodingKeys: CodingKey {
        case type
        case meta
    }
    
    struct WhenPageReachedMeta: Codable {
        let url: String
    }

    struct OnCommandExecutionMeta: Codable {
        let command: String
    }

    struct OnEventMeta: Codable {
        let event: String
    }

    struct WhenElementAppearsMeta: Codable {
        let selector: String
    }
    
    case whenConditionsPass
    case whenPageReached(WhenPageReachedMeta)
    case onCommandExecution(OnCommandExecutionMeta)
    case onEvent(OnEventMeta)
    case whenElementAppears(WhenElementAppearsMeta)
    case onUserConfusion
    case onRageClick
    case smartDelay
    case whenShareLinkViewed
    
    static func ==(lhs: PushTrigger, rhs: PushTrigger) -> Bool {
        switch (lhs, rhs) {
        case (.whenConditionsPass, .whenConditionsPass),
             (.onUserConfusion, .onUserConfusion),
             (.onRageClick, .onRageClick),
             (.smartDelay, .smartDelay),
             (.whenShareLinkViewed, .whenShareLinkViewed):
            return true
        
        case let (.whenPageReached(meta1), .whenPageReached(meta2)):
            return meta1.url == meta2.url
        
        case let (.onCommandExecution(meta1), .onCommandExecution(meta2)):
            return meta1.command == meta2.command
        
        case let (.onEvent(meta1), .onEvent(meta2)):
            return meta1.event == meta2.event

        case let (.whenElementAppears(meta1), .whenElementAppears(meta2)):
            return meta1.selector == meta2.selector
            
        default:
            return false
        }
    }
    
    static func !=(lhs: PushTrigger, rhs: PushTrigger) -> Bool {
        return !(lhs == rhs)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "when_page_reached":
            let meta = try container.decode(WhenPageReachedMeta.self, forKey: .meta)
            self = .whenPageReached(meta)
        case "on_command_execution":
            let meta = try container.decode(OnCommandExecutionMeta.self, forKey: .meta)
            self = .onCommandExecution(meta)
        case "on_event":
            let meta = try container.decode(OnEventMeta.self, forKey: .meta)
            self = .onEvent(meta)
        case "when_element_appears":
            let meta = try container.decode(WhenElementAppearsMeta.self, forKey: .meta)
            self = .whenElementAppears(meta)
        case "when_conditions_pass":
            self = .whenConditionsPass
        case "on_user_confusion":
            self = .onUserConfusion
        case "on_rage_click":
            self = .onRageClick
        case "smart_delay":
            self = .smartDelay
        case "when_share_link_viewed":
            self = .whenShareLinkViewed
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .whenPageReached(let meta):
            try container.encode("when_page_reached", forKey: .type)
            try container.encode(meta, forKey: .meta)
        case .onCommandExecution(let meta):
            try container.encode("on_command_execution", forKey: .type)
            try container.encode(meta, forKey: .meta)
        case .onEvent(let meta):
            try container.encode("on_event", forKey: .type)
            try container.encode(meta, forKey: .meta)
        case .whenElementAppears(let meta):
            try container.encode("when_element_appears", forKey: .type)
            try container.encode(meta, forKey: .meta)
        case .whenConditionsPass:
            try container.encode("when_conditions_pass", forKey: .type)
        case .onUserConfusion:
            try container.encode("on_user_confusion", forKey: .type)
        case .onRageClick:
            try container.encode("on_rage_click", forKey: .type)
        case .smartDelay:
            try container.encode("smart_delay", forKey: .type)
        case .whenShareLinkViewed:
            try container.encode("when_share_link_viewed", forKey: .type)
        }
    }
}
