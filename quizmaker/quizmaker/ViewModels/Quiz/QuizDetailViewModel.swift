
import RxSwift
import RxCocoa

public class QuizDetailViewModel {
    
    var quiz: Quiz
    
    let items: BehaviorRelay<[DetailSectionModel]>
    private let disposeBag = DisposeBag()
    
    let failure: PublishSubject<NetworkError>
    let success: PublishSubject<Void>
    
    let loadPageTrigger: PublishSubject<Void>
    let deleteTrigger: PublishSubject<Void>
    
    init(quiz: Quiz) {
        self.quiz = quiz
        
        failure = PublishSubject()
        success = PublishSubject()
        items = BehaviorRelay(value: [])
        
        loadPageTrigger = PublishSubject()
        deleteTrigger = PublishSubject()
        
        deleteTrigger.asObservable()
            .subscribe(onNext: { [unowned self] (_) in
                self.delete()
            }).disposed(by: disposeBag)
        
        loadPageTrigger.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                guard let strongSelf = self else { return }
                
                let detailSection = QuizDetailSectionModel.detail(item: quiz)
                let questionSection = QuizDetailSectionModel.questions(item: quiz.questions)
                var sections: [DetailSectionModel] = [
                    .detail(item: detailSection),
                ]
                
                let endpoint = QuizEndpoint.participants(quizID: strongSelf.quiz.id)
                NetworkManager.shared.request(endpoint, [QuizParticipant].self)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success(let participants):
                            
                            let participantSection = QuizDetailSectionModel.participants(item: participants)
                            sections.append(.participants(item: participantSection))
                            sections.append(.questions(item: questionSection))
                            
                        case .failure(let error):
                            strongSelf.failure.onNext(error)
                        }
                        
                        strongSelf.items.accept(sections)
                    }).disposed(by: strongSelf.disposeBag)
                
            }).disposed(by: disposeBag)
    }
    
    func updateQuiz(quiz: Quiz) {
        self.quiz = quiz
        var currentSections = items.value
        currentSections.remove(at: 0)
        currentSections.insert(.detail(item: .detail(item: quiz)), at: 0)
        self.items.accept(currentSections)
    }
    
    func updateQuiz(quiz: Quiz, questions: [Question]) {
        self.quiz = quiz
        var currentSections = items.value
        currentSections.remove(at: 0)
        currentSections.insert(.detail(item: .detail(item: quiz)), at: 0)
        currentSections.remove(at: 2)
        currentSections.insert(.questions(item: .questions(item: questions)), at: 2)
        self.items.accept(currentSections)
    }
    
    private func delete() {
        let endpoint = QuizEndpoint.delete(quizID: quiz.id)
        NetworkManager.shared.requestJSON(endpoint, .apiMessage)
            .subscribe(onNext: { [weak self] (result) in
                switch result {
                case .success:
                    self?.success.onNext(())
                case .failure(let error):
                    self?.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
}