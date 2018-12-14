
import Foundation
import RxSwift
import RxCocoa

public class ParticipantAnswerViewModel {
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    let answers: BehaviorRelay<[ParticipantAnswer]>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    init(quizID: Int, userID: Int) {
        
        answers = BehaviorRelay(value: [])
        loadPageTrigger = PublishSubject()
        failure = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap({ [weak self] (_) -> Observable<[ParticipantAnswer]> in
                guard let strongSelf = self else { return .empty() }
                let endpoint = QuizEndpoint.ownerParticipantAnswer(quizID: quizID, userID: userID)
                return strongSelf.fetch(endpoint)
            }).bind(to: answers)
            .disposed(by: disposeBag)
    }
    
    public func fetch(_ endpoint: QuizEndpoint) -> Observable<[ParticipantAnswer]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            NetworkManager.shared.request(endpoint, [ParticipantAnswer].self, .apiMessage)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let object):
                        observer.onNext(object)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
}
