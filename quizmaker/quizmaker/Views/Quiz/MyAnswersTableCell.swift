
import UIKit

/// :nodoc:
public class MyAnswersTableCell: UITableViewCell {
    
    let answerLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let realAnswerLabel: UILabel = {
        return UILabel.uiLabel(0, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let participantPointLabel: UILabel = {
        return UILabel.uiLabel(2, .byWordWrapping, "", .center, .gray, .systemFont(ofSize: 18), true, false)
    }()
    
    let pointLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let infoLabel: UILabel = {
        let lbl = UILabel.uiLabel(1, .byTruncatingTail, "Not Validated Yet", .left, .black, .systemFont(ofSize: 14), true, false)
        lbl.textColor = .red
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [questionLabel, realAnswerLabel, answerLabel, pointLabel, infoLabel])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let horizontalStack = UIStackView(arrangedSubviews: [stackView, participantPointLabel,])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 10
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        participantPointLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configure(_ element: ParticipantAnswer) {
        let number = "\(element.question.number)"
        questionLabel.text = "Question \(number): \(element.question.question)"
        realAnswerLabel.text = "Answer \(number): \(element.question.answer)"
        answerLabel.text = "Your Answer: \(element.answer)"
        
        if let qPoint = element.question.point {
            pointLabel.isHidden = false
            pointLabel.text = "Total: \(qPoint) point"
        } else {
            pointLabel.isHidden = true
        }
        
        if let type = QuestionType(rawValue: element.question.questionType) {
            
            switch type {
            case .multichoice, .truefalse:
                infoLabel.isHidden = true
                participantPointLabel.isHidden = false

                if let pPoint = element.point {
                    participantPointLabel.text = "GETS \(pPoint)"
                }
                
            case .text:
                
                if let validated = element.isValidated, validated {
                    infoLabel.isHidden = true
                    participantPointLabel.isHidden = false
                    
                    if let pPoint = element.point {
                        participantPointLabel.text = "GETS \(pPoint)"
                    }
                } else {
                    infoLabel.isHidden = false
                    participantPointLabel.isHidden = true
                }
            }
        }
    }
}
