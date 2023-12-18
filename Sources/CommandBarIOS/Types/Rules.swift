import Foundation

enum Operator: String {
    case isTrue = "isTrue"
    case isFalse = "isFalse"
    case isTruthy = "isTruthy"
    case isFalsy = "isFalsy"
    case startsWith = "startsWith"
    case endsWith = "endsWith"
    case matchesRegex = "matchesRegex"
    case isGreaterThan = "isGreaterThan"
    case isLessThan = "isLessThan"
    case isBefore = "isBefore"
    case isAfter = "isAfter"
    case isDefined = "isDefined"
    case isNotDefined = "isNotDefined"
    case classnameOnPage = "classnameOnPage"
    case idOnPage = "idOnPage"
    case selectorOnPage = "selectorOnPage"
    case classnameNotOnPage = "classnameNotOnPage"
    case idNotOnPage = "idNotOnPage"
    case selectorNotOnPage = "selectorNotOnPage"
    case isOp = "is"
    case isNot = "isNot"
    case includes = "includes"
    case doesNotInclude = "doesNotInclude"
}

enum InteractionStateV: String {
    case viewed = "viewed"
    case completed = "completed"
    case dismissed = "dismissed"
}

struct NudgeInteractionCondition {
    var type: String = "nudge_interaction"
    var operatorV: Operator
    var value: InteractionStateV
    var nudge_id: Int
    var reason: String?
}

struct QuestlistInteractionCondition {
    var type: String = "questlist_interaction"
    var operatorV: Operator
    var value: InteractionStateV
    var questlist_id: Int
    var reason: String?
}

protocol ConditionProtocol {
    var type: String { get set }
    var condition_operator: Operator { get set }
}

class ConditionBase: ConditionProtocol {
    var type: String
    var condition_operator: Operator
    var field: String?
    var value: String?
    var reason: String?
    var rule_id: String?

    init(type: String, conditionOperator: Operator) {
        self.type = type
        self.condition_operator = conditionOperator
    }
}

struct MultiValueCondition: ConditionProtocol {
    var type: String
    var condition_operator: Operator
    var values: [String]
    var reason: String?
}

enum RuleExpressionType: String {
    case AND = "AND"
    case OR = "OR"
    case LITERAL = "LITERAL"
    case CONDITION = "CONDITION"
}

protocol RuleExpression {
    var type: RuleExpressionType { get set }
}

struct RuleExpressionAnd: RuleExpression {
    var type: RuleExpressionType = .AND
    var exprs: [RuleExpression]
}

struct RuleExpressionOr: RuleExpression {
    var type: RuleExpressionType = .OR
    var exprs: [RuleExpression]
}

struct RuleExpressionLiteral: RuleExpression {
    var type: RuleExpressionType = .LITERAL
    var value: Bool
}

struct RuleExpressionCondition: RuleExpression {
    var type: RuleExpressionType = .CONDITION
    var condition: ConditionProtocol
}

struct NamedRuleReference {
    var type: String = "named_rule"
    var rule_id: Either<Int, String> // Using Either to represent Union
    var reason: String?
}


struct Audience {
    var type: String
    var expression: RuleExpression?
    var rule_reference: NamedRuleReference?
}
