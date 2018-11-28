
import Foundation

public struct ErrorMessage {
    var message: String
}

extension ErrorMessage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
}