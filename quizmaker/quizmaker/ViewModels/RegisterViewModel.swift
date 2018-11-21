import Foundation
import RxCocoa
import RxSwift

class RegisterViewModel {
    
    let username: BehaviorRelay<String>
    let password: BehaviorRelay<String>
    let email: BehaviorRelay<String>
    let firstName: BehaviorRelay<String>
    let userType: BehaviorRelay<UserType>
    let lastName: BehaviorRelay<String>
    let studentId: BehaviorRelay<String?>
    
    var validEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: email.value)
    }
    
    var registerSuccess: ((SignUp) -> Void)?
    var error: ((NetworkError) -> Void)?
    
    let registerTrigger: PublishSubject<Void>
    let disposeBag = DisposeBag()
    
    init() {
        username = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        email = BehaviorRelay(value: "")
        firstName = BehaviorRelay(value: "")
        lastName = BehaviorRelay(value: "")
        studentId = BehaviorRelay(value: nil)
        userType = BehaviorRelay(value: .normal)
        
        registerTrigger = PublishSubject()
        subscribeRegister()
    }
    
    private func subscribeRegister() {
        registerTrigger.asObservable()
            .subscribe(onNext: { [unowned self] () in
                let signUp = SignUp(username: self.username.value, firstName: self.firstName.value, lastName: self.lastName.value, email: self.email.value, password: self.password.value, userType: self.userType.value, studentId: self.studentId.value)
                
                let endpoint = AuthenticationEndpoint.register(signUp: signUp)
                NetworkManager.shared.request(endpoint, SignUp.self, ErrorType.register)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success(let signUp):
                            self.registerSuccess?(signUp)
                        case .failure(let error):
                            self.error?(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}