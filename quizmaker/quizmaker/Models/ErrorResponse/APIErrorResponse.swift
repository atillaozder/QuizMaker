
import Foundation

protocol ErrorResponse {
    var error: String { get }
    var errorDesc: String { get }
    var errorCode: Int? { get }
}

public struct APIErrorResponse: ErrorResponse {
    var error: String
    var errorDesc: String
    var errorCode: Int?
}

extension APIErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case error
        case errorDesc = "error_description"
        case errorCode = "error_code"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        error = try container.decode(String.self, forKey: .error)
        errorDesc = try container.decode(String.self, forKey: .errorDesc)
        if let code = try? container.decodeIfPresent(Int.self, forKey: .errorCode) {
            errorCode = code
        } else {
            guard let codeStr = try container.decodeIfPresent(String.self, forKey: .errorCode) else { return }
            errorCode = Int(codeStr)
        }
    }
}