// TODO: Organize better

struct NumberResponseEvent: Codable {
    var type: String
    let value: Int
    let emoji: String?
    let max: Int
    
    init(value: Int, max: Int, emoji: String? = nil) {
        type = "number"
        self.value = value
        self.emoji = emoji
        self.max = max
    }
}

struct StringResponseEvent: Codable {
    var type: String
    
    let value: String
    
    init(value: String) {
        type = "string"
        self.value = value
    }
}

struct ArrayResponseEvent: Codable {
    var type: String
    let value: [String]
    
    init(value: [String]) {
        type = "string"
        self.value = value
    }
}

enum ResponseEvent: Codable {
    case number(NumberResponseEvent)
    case string(StringResponseEvent)
    case array(ArrayResponseEvent)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(NumberResponseEvent.self) {
            self = .number(x)
            return
        }
        if let x = try? container.decode(StringResponseEvent.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(ArrayResponseEvent.self) {
            self = .array(x)
            return
        }
        throw DecodingError.typeMismatch(ResponseEvent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ResponseEvent"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .array(let x):
            try container.encode(x)
        }
    }
}

struct Status: Codable {
    let is_preview: Bool
    let is_live: Bool
}


protocol EventData: Codable {
    var type: EventType { get set}
}

enum EventType : String, Codable {
  case surveyResponse = "survey_response"
}

enum AnalyticsType: String, Codable {
    case track = "t"
    case identify = "i"
    case log = "l"
    case availability = "a"
    case error = "e"
}

enum EventName : String, Codable {
    case surveyResponse = "Survey response"
}
    
enum UserType: String, Codable {
    case admin, likelyAdmin = "likely-admin", endUser = "end_user"
}

struct FormFactorConfig: Codable {
    var type = "modal"
}


struct NudgeEvent: Codable {
    struct NudgeStepEvent : Codable {
        var id: String
        var title: String
    }
    
    var id: String
    var trigger: PushTrigger
    var template_source:String
    var slug: String
    var frequency_limit: String = "no_limit"
    var step:NudgeStepEvent
    var status: Status
}

struct EventAttributes: Codable {
    var type: AnalyticsType
    var response: ResponseEvent?
    var nudge: NudgeEvent?
    var formFactor = "modal"
}

struct EventPayload: Codable {
    struct Context: Codable {
        struct Page: Codable {
            let path: String?
            let title: String?
            let url: String?
            let search: String?
        }
        
        let page: Page?
        let userAgent: String?
        let groupId: String?
        let cbSource: String?
    }


    let context: Context
    let userType: UserType
    let type: AnalyticsType
    let attrs: EventAttributes?
    let name: EventName?
    let id: String?
    let session: String?
    let search: String?
    let reportToSegment: Bool
    let fingerprint: String?
    let clientEventTimestamp: String
    let clientFlushedTimestamp: String?

    enum UserType: String, Codable {
        case admin, likelyAdmin = "likely-admin", endUser = "end_user"
    }
}

struct AnalyticsTrackBody: Codable {
    let events: [EventPayload]
    let organization: String
    let id: String?
}


struct UserProperties: Codable {
    var id: String? = nil;
}

struct AnalyticsIdentifyBody:Codable {
    var organization_id: String
    var distinct_id: String?
    var properties: UserProperties
}
