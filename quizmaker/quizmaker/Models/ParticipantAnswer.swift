import Foundation

struct ParticipantAnswer: Codable {
    let id: Int
    let question: Question
    let answer: String
    let participantID: Int
    let isCorrect: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, question, answer
        case participantID = "participant_id"
        case isCorrect = "is_correct"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        question = try container.decode(Question.self, forKey: .question)
        answer = try container.decode(String.self, forKey: .answer)
        participantID = try container.decode(Int.self, forKey: .participantID)
        isCorrect = try container.decodeIfPresent(Bool.self, forKey: .isCorrect)
    }
}