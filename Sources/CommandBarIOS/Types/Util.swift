enum Either<L: Codable, R: Codable>: Codable {
    case left(L)
    case right(R)
    
    enum CodingKeys: CodingKey {
        case left
        case right
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let leftValue = try? container.decode(L.self, forKey: .left) {
            self = .left(leftValue)
            return
        }
        if let rightValue = try? container.decode(R.self, forKey: .right) {
            self = .right(rightValue)
            return
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Data doesn't match"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .left(let value):
            try container.encode(value, forKey: .left)
        case .right(let value):
            try container.encode(value, forKey: .right)
        }
    }
}
