struct NudgeConditionalAction : Codable {
    enum Operator: String, Codable {
        case eq, neq, gt, lt
    }
    var `operator`: Operator
    var operand: Int
    var action: Action?
}

struct NudgeContentMarkdownBlockMeta: Codable {
    var value: String?
}

struct NudgeContentImageBlockMeta : Codable {
    var src: String?
    var file_name: String?
    var size: String?
}

struct NudgeContentVideoBlockMeta : Codable{
    
    enum VideoType: String, Codable {
        case url = "url"
        case command = "command"
    }

    var type: VideoType
    var src: String?
    var command: String?
}

struct NudgeContentHelpDocBlockMeta: Codable {
    var type = "command"
    var command: String?
}

struct NudgeContentButtonBlockMeta: Codable {
    enum ButtonType: String, Codable {
       case primary = "primary"
        case secondary = "secondary"
        case snooze = "snooze"
    }

    var label: String?
    var action: Action
    var button_type: ButtonType? = .primary
    var conditional_actions: [NudgeConditionalAction]?
}

struct NudgeContentSurveyTextBlockMeta: Codable {
    var prompt: String
}

// TODO: Make better enum
struct NudgeContentSurveyRatingBlockMeta: Codable {
    var lower_label: String?
    var upper_label: String?
    var options: Int?
    var emojis: [String]?
    var type: String
}

struct NudgeStepContentSurveyTextShortBlockMeta : Codable {
    var prompt: String
}


struct NudgeContentListBlockMeta : Codable{
    enum ListType: String, Codable {
        case single = "single"
        case multiple = "multiple"
    }
    
    enum DisplayType: String, Codable {
        case dropdown = "dropdown"
        case list = "list"
        case grid = "grid"
    }
    
    var options: [String]
    var display_type: DisplayType
    var list_type: ListType
    
}

enum NudgeContentBlockType:String, Codable {
    case markdown = "markdown"
    case image = "image"
    case video = "video"
    case helpDoc = "help_doc_command"
    case button = "button"
    case surveyText = "survey_text"
    case surveyRating = "survey_rating"
    case surveyTextShort = "survey_text_short"
    case contentList = "survey_list"
}

struct NudgeContentBlock: Codable {
    var type: NudgeContentBlockType
    var sort_key: Int?
    var meta: NudgeContentBlockMeta
  
    enum CodingKeys: String, CodingKey {
        case type, sort_key, meta
    }
  
    init(type: NudgeContentBlockType, meta: NudgeContentBlockMeta, sort_key: Int? = nil) {
        self.type = type
        self.meta = meta
        self.sort_key = sort_key
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
  
        type = try container.decode(NudgeContentBlockType.self, forKey: .type)
        sort_key = try container.decodeIfPresent(Int.self, forKey: .sort_key)
        
        let metaDecoder = try container.superDecoder(forKey: .meta)
        meta = try NudgeContentBlockMeta(from: metaDecoder, type: type)
    }
}

enum NudgeContentBlockMeta: Codable {
    case markdown(NudgeContentMarkdownBlockMeta)
    case image(NudgeContentImageBlockMeta)
    case video(NudgeContentVideoBlockMeta)
    case helpDoc(NudgeContentHelpDocBlockMeta)
    case button(NudgeContentButtonBlockMeta)
    case surveyText(NudgeContentSurveyTextBlockMeta)
    case surveyRating(NudgeContentSurveyRatingBlockMeta)
    case surveyTextShort(NudgeStepContentSurveyTextShortBlockMeta)
    case contentList(NudgeContentListBlockMeta)
    
    init(from decoder: Decoder, type: NudgeContentBlockType) throws {
        let container = try decoder.singleValueContainer()
        
        switch type {
        case .markdown:
            let value = try container.decode(NudgeContentMarkdownBlockMeta.self)
            self = .markdown(value)
        case .image:
            let value = try container.decode(NudgeContentImageBlockMeta.self)
            self = .image(value)
        case .video:
            let value = try container.decode(NudgeContentVideoBlockMeta.self)
            self = .video(value)
        case .helpDoc:
            let value = try container.decode(NudgeContentHelpDocBlockMeta.self)
            self = .helpDoc(value)
        case .button:
            let value = try container.decode(NudgeContentButtonBlockMeta.self)
            self = .button(value)
        case .surveyText:
            let value = try container.decode(NudgeContentSurveyTextBlockMeta.self)
            self = .surveyText(value)
        case .surveyRating:
            let value = try container.decode(NudgeContentSurveyRatingBlockMeta.self)
            self = .surveyRating(value)
        case .surveyTextShort:
            let value = try container.decode(NudgeStepContentSurveyTextShortBlockMeta.self)
            self = .surveyTextShort(value)
        case .contentList:
            let value = try container.decode(NudgeContentListBlockMeta.self)
            self = .contentList(value)
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .markdown(let value):
            try container.encode(value)
        case .image(let value):
            try container.encode(value)
        case .video(let value):
            try container.encode(value)
        case .helpDoc(let value):
            try container.encode(value)
        case .button(let value):
            try container.encode(value)
        case .surveyText(let value):
            try container.encode(value)
        case .surveyRating(let value):
            try container.encode(value)
        case .surveyTextShort(let value):
            try container.encode(value)
        case .contentList(let value):
            try container.encode(value)
        }
    }
}


struct FormFactor : Codable {
    var type: FormFactorType
        
    // Popover
    var position: Position?
    
    // Pin
    var anchor: String?
    var is_open_by_default: Bool?
    var is_showing_mask: Bool?
    var advance_trigger: String?
    var offset: OffSet?
}

enum FormFactorType: String, Codable {
    case modal = "modal"
    case popover = "popover"
    case pin = "pin"
    case clip = "clip"
}

enum Position: String, Codable {
    case topLeft = "top-left"
    case topRight = "top-right"
    case bottomRight = "bottom-right"
    case bottomLeft = "bottom-left"
    case center = "center"
}

struct PinDetail: Codable {
    var anchor: String
    var is_open_by_default: Bool?
    var is_showing_mask: Bool?
    var advance_trigger: String?
    var offset: OffSet
}

struct OffSet: Codable {
    var x: String
    var y: String
}

struct NudgeStep : Codable {
    var id: Int
    var title: String
    var content: [NudgeContentBlock]
    var is_live: Bool
    // Additional
    var form_factor: FormFactor
    var has_survey_response: Bool?
}

enum NudgeType: String, Codable {
    case announcement = "announcement"
    case productTour = "product_tour"
    case survey = "survey"
}


struct Nudge : Codable {
    // Nudge Bases
    var slug: String
    var id: String
    var organization: String
    var trigger: PushTrigger

    var steps: [NudgeStep]
    var is_live: Bool
    var old_nudge_id: Int?
    var archived: Bool
    
    // Nudge Additional
    var template_source: String
    var show_step_counter: Bool
    var dismissible: Bool
    var snoozable: Bool
    var animatable: Bool
    var share_page_url: String
    var copilot_suggest: Bool
    var copilot_cta_label: String
    var copilot_description: String
    var is_scheduled: Bool
    var scheduled_start_time: String?
    var scheduled_end_time: String?
    var snooze_label: String?
    var type: NudgeType?
    
    
    static func buildFakeNudge() -> Nudge {
        
        let surveyRatingContent = NudgeContentBlock(type: .surveyRating, meta: .surveyRating(NudgeContentSurveyRatingBlockMeta(lower_label: "Hate it", upper_label: "Love It", options: 5, emojis: ["😡", "😐", "😍"], type: "emojis" )))
        let continueContent = NudgeContentBlock(type: .button, meta: .button(NudgeContentButtonBlockMeta(label: "Continue", action: .nudge(NudgeAction(type: "nudge", value: 1)))))
        let doneContent = NudgeContentBlock(type: .button, meta: .button(NudgeContentButtonBlockMeta(label: "Done", action: .nudge(NudgeAction(type: "nudge", value: 1)))))
        
        let imageContent = NudgeContentBlock(type: .image, meta: .image(NudgeContentImageBlockMeta(src: "https://picsum.photos/536/354")))
        
        let videoContent = NudgeContentBlock(type: .video, meta: .video(NudgeContentVideoBlockMeta(type: .url, src: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")))
        let modalContent = [NudgeContentBlock(type: .markdown, meta: .markdown(NudgeContentMarkdownBlockMeta(value: "Let's walkthough some __Native Nudges__ and how they can be used! This is a **Modal Nudge**!"))), imageContent, continueContent]
        
        let modalContent2 = [NudgeContentBlock(type: .surveyTextShort, meta: .surveyTextShort(NudgeStepContentSurveyTextShortBlockMeta(prompt: "Enter your feedback"))), continueContent]
        
        let modalContent3 = [NudgeContentBlock(type: .surveyText, meta: .surveyText(NudgeContentSurveyTextBlockMeta(prompt: "Enter your feedback"))), continueContent]
        
        let popoverContent = [NudgeContentBlock(type: .markdown, meta: .markdown(NudgeContentMarkdownBlockMeta(value: "This is a **Popover Nudge**, it supports Markdown so [links](https://commandbar.com) work and multiple buttons! You can drag it around too, give it a try!"))), videoContent, continueContent]
        
        let clipContent = [NudgeContentBlock(type: .markdown, meta: .markdown(NudgeContentMarkdownBlockMeta(value: "This is a shiny new ✨ **Clip Nudge** ✨, exclusive to Mobile! You can dismiss by dragging down, but **don't forget to leave feedback!** 🙏"))), surveyRatingContent, doneContent]
        
        
        let step1 = NudgeStep(id: 1, title: "Welcome!", content: modalContent, is_live: true, form_factor: FormFactor(type: .modal))
        let step2 = NudgeStep(id: 1, title: "Short Survey", content: modalContent2, is_live: true, form_factor: FormFactor(type: .modal))
        let step3 = NudgeStep(id: 1, title: "Long Survey", content: modalContent3, is_live: true, form_factor: FormFactor(type: .modal))
        let step4 = NudgeStep(id: 1, title: "Drag Me!", content: popoverContent, is_live: true, form_factor: FormFactor(type: .popover))
        let step5 = NudgeStep(id: 1, title: "Leave feedback", content: clipContent, is_live: true, form_factor: FormFactor(type: .clip))
        
        let steps = [step5, step1, step2, step3, step4, step5]
        return Nudge(slug: "test-nudge", id: "test", organization: "foocorp", steps: steps, is_live: true, old_nudge_id: nil, archived: false, template_source: "", show_step_counter: true, dismissible: true, snoozable: false, share_page_url: "/share", copilot_suggest: false, copilot_cta_label: "", copilot_description: "", is_scheduled: false, scheduled_start_time: nil, scheduled_end_time: nil, snooze_label: "Snooze", animatable: true, type: NudgeType.announcement, trigger: .whenConditionsPass)
    }
    
    init(slug: String, id: String, organization: String, steps: [NudgeStep], is_live: Bool, old_nudge_id: Int?, archived: Bool?, template_source: String, show_step_counter: Bool, dismissible: Bool, snoozable: Bool,
    share_page_url: String,
    copilot_suggest: Bool,
    copilot_cta_label: String,
    copilot_description: String,
    is_scheduled: Bool,
    scheduled_start_time: String?,
    scheduled_end_time: String?,
    snooze_label: String,
         animatable: Bool,
         type: NudgeType?, trigger: PushTrigger) {
        self.slug = slug
        self.id = id
        self.organization = organization
        self.steps = steps
        self.is_live = is_live
        self.old_nudge_id = old_nudge_id
        self.archived = archived ?? false
        self.template_source = template_source
        self.show_step_counter = show_step_counter
        self.dismissible = dismissible
        self.snoozable = snoozable
        self.share_page_url = share_page_url
        self.copilot_suggest = copilot_suggest
        self.copilot_cta_label = copilot_cta_label
        self.copilot_description = copilot_description
        self.is_scheduled = is_scheduled

        self.scheduled_start_time = scheduled_start_time
        self.scheduled_end_time = scheduled_end_time
        self.snooze_label = snooze_label
        self.type = type
        self.animatable = animatable
        self.trigger = trigger
    }

    enum CodingKeys: String, CodingKey {
            case slug, id, organization, steps, is_live, old_nudge_id, archived,
            template_source, show_step_counter, dismissible, snoozable, share_page_url, copilot_suggest, copilot_cta_label,
            copilot_description, is_scheduled, scheduled_start_time, scheduled_end_time, snooze_label, type, animatable, trigger
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            slug = try container.decode(String.self, forKey: .slug)
            organization = try container.decode(String.self, forKey: .organization)
            steps = try container.decode([NudgeStep].self, forKey: .steps)
            is_live = try container.decode(Bool.self, forKey: .is_live)
            old_nudge_id = try container.decodeIfPresent(Int.self, forKey: .old_nudge_id)
            archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            
            // Nudge Additional
            template_source = try container.decode(String.self, forKey: .template_source)
            show_step_counter = try container.decode(Bool.self, forKey: .show_step_counter)
            dismissible = try container.decode(Bool.self, forKey: .dismissible)
            snoozable = try container.decode(Bool.self, forKey: .snoozable)
            share_page_url = try container.decode(String.self, forKey: .share_page_url)
            copilot_suggest = try container.decode(Bool.self, forKey: .copilot_suggest)
            copilot_cta_label = try container.decode(String.self, forKey: .copilot_cta_label)
            copilot_description = try container.decode(String.self, forKey: .copilot_description)
            is_scheduled = try container.decode(Bool.self, forKey: .is_scheduled)
            scheduled_start_time = try container.decodeIfPresent(String.self, forKey: .scheduled_start_time)
            scheduled_end_time = try container.decodeIfPresent(String.self, forKey: .scheduled_end_time)
            snooze_label = try container.decodeIfPresent(String.self, forKey: .snooze_label)
            type = try container.decodeIfPresent(NudgeType.self, forKey: .type)
            animatable = try container.decodeIfPresent(Bool.self, forKey: .animatable) ?? true
            trigger = try container.decode(PushTrigger.self, forKey: .trigger)
            
            do {
                if let intValue = try? container.decode(Int.self, forKey: .id) {
                    id = String(intValue)
                } else {
                    id = try container.decode(String.self, forKey: .id)
                }
            } catch {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Invalid value for id.")
            }
        }
}
