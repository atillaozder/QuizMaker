
import UIKit
import RxSwift
import RxCocoa

/// :nodoc:
protocol PercentageUpdateDelegate: class {
    func updateQuiz(quiz: Quiz)
}

/// Provider to update a quiz.
public class QuizUpdateViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: QuizUpdateViewModel
    
    private let percentageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Percentage* Ex: '15.25'"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .decimalPad
        tf.returnKeyType = .next
        tf.tag = 0
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "percentage").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        return tf
    }()
    
    private lazy var createButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    }()
    
    /// :nodoc:
    weak var delegate: PercentageUpdateDelegate?
    
    
    /**
     Constructor of the class.
     
     - Parameters:
        - quiz: the quiz instance.
     
     - Precondition: `quiz` must be non-nil.
     
     - Postcondition:
     Controller will be initialized.
     */
    init(quiz: Quiz) {
        viewModel = QuizUpdateViewModel(quiz: quiz)
        self.percentageTextField.text = "\(quiz.percentage)"
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.setRightBarButton(createButton, animated: true)
        self.navigationItem.title = "Quiz Update"
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        view.addSubview(percentageTextField)
        percentageTextField.setAnchors(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, spacing: UIEdgeInsets.init(top: 10, left: 16, bottom: 0, right: -16))
        percentageTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bindUI()
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        percentageTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .map { [unowned self] (text) -> Double in
                
                if var percentage = Double(text) {
                    
                    if floor(percentage) != percentage {
                        percentage = (percentage * 100).rounded() / 100
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    if percentage == 0 {
                        percentage = 1
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    if percentage > 100 {
                        percentage = 100
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    return percentage
                }
                
                self.percentageTextField.text = ""
                return -1
            }.bind(to: viewModel.percentage)
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
            }).subscribe(onNext: { [unowned self] (_) in
                let title = "Update Quiz"
                let alertController = UIAlertController(title: "Are you sure?", message: "This operation cannot be undo", preferredStyle: .alert)
                let ok = UIAlertAction(title: title, style: .default, handler: { (_) in
                    self.createButton.isEnabled = false
                    self.viewModel.updateTrigger.onNext(())
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alertController.addAction(cancel)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.failure.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                self.createButton.isEnabled = true
                print(error.localizedDescription)
                switch error {
                case .quiz(.create(let response)):
                    self.showErrorAlert(message: response.percentage?.first ?? "An error occupied")
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        viewModel.success.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let title = "Quiz has successfully updated."
                self.delegate?.updateQuiz(quiz: self.viewModel.quiz)
                self.showDismissAlert(title)
            }).disposed(by: disposeBag)
    }
}
