
import UIKit
import RxSwift

public class ChangePasswordViewController: UIViewController, KeyboardHandler {
    
    private let viewModel = ChangePasswordViewModel()
    private let disposeBag = DisposeBag()
    
    public let scrollView: UIScrollView = UIScrollView()
    public let contentView: UIView = UIView()
    
    private let oldPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Old Password*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "password").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        
        let button = UIButton(image: "show-password")
        button.tag = tf.tag
        button.addTarget(self, action: #selector(oldPasswordShowPassword(_:)), for: .touchUpInside)
        tf.rightView = button
        tf.rightViewMode = .always
        return tf
    }()
    
    private lazy var oldPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: oldPasswordErrorLabel)
    }()
    
    private lazy var oldPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New Password*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 1
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
        icon.image = UIImage(imageLiteralResourceName: "password").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        
        let button = UIButton(image: "show-password")
        button.tag = tf.tag
        button.addTarget(self, action: #selector(newPasswordShowPassword(_:)), for: .touchUpInside)
        tf.rightView = button
        tf.rightViewMode = .always
        return tf
    }()
    
    private lazy var newPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: newPasswordErrorLabel)
    }()
    
    private lazy var newPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 2
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
        icon.image = UIImage(imageLiteralResourceName: "password").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        
        let button = UIButton(image: "show-password")
        button.tag = tf.tag
        button.addTarget(self, action: #selector(confirmPasswordShowPassword(_:)), for: .touchUpInside)
        tf.rightView = button
        tf.rightViewMode = .always
        return tf
    }()
    
    private lazy var confirmPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: confirmPasswordErrorLabel)
    }()
    
    private lazy var confirmPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let changePasswordButton: IndicatorButton = {
        let button = IndicatorButton(title: "Change Password")
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.bindUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        changePasswordButton.layoutIfNeeded()
        changePasswordButton.roundCorners(.allCorners, radius: changePasswordButton.frame.size.height / 2)
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        setupViews()
        scrollView.showsVerticalScrollIndicator = false
        
        self.navigationItem.title = "Change Password"
        
        if #available(iOS 12, *) {
            oldPasswordTextField.textContentType = .oneTimeCode
            newPasswordTextField.textContentType = .oneTimeCode
            confirmPasswordTextField.textContentType = .oneTimeCode
        } else {
            oldPasswordTextField.textContentType = .init(rawValue: "")
            newPasswordTextField.textContentType = .init(rawValue: "")
            confirmPasswordTextField.textContentType = .init(rawValue: "")
        }
        
        let subviews = [
            oldPasswordTextField,
            oldPasswordErrorWrapper,
            newPasswordTextField,
            newPasswordErrorWrapper,
            confirmPasswordTextField,
            confirmPasswordErrorWrapper,
            changePasswordButton
        ]
        
        let stackView = UIView.uiStackView(arrangedSubviews: subviews, .fill, .center, .vertical, 20)
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: contentView.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        
        changePasswordButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        NSLayoutConstraint.activate([
            oldPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            newPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            confirmPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            changePasswordButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3/4),
            
            oldPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),
            newPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),
            
            oldPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            newPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            confirmPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            ])
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    private func bindUI() {
        oldPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.oldPassword)
            .disposed(by: disposeBag)
        
        newPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.newPassword)
            .disposed(by: disposeBag)
        
        confirmPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.confirmPassword)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.oldPassword.asObservable(), viewModel.newPassword.asObservable(), viewModel.confirmPassword.asObservable())
            .map { (old, new, confirm) -> Bool in
                return !old.isEmpty && !new.isEmpty && !confirm.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.changePasswordButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: changePasswordButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
                self.clearFields()
                self.changePasswordButton.showLoading()
            })
            .bind(to: viewModel.changePasswordTrigger)
            .disposed(by: disposeBag)
        
        viewModel.success = { [unowned self] () in
            self.changePasswordButton.hideLoading()
            self.showDismissAlert("Password has been successfully changed")
        }
        
        viewModel.failure = { [unowned self] (error) in
            print(error.localizedDescription)
            self.changePasswordButton.hideLoading()
            switch error {
            case .update(.changePassword(let response)):
                self.handleError(response)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    private func oldPasswordShowPassword(_ sender: UIButton) {
        oldPasswordTextField.isSecureTextEntry = !oldPasswordTextField.isSecureTextEntry
        sender.tintColor = oldPasswordTextField.isSecureTextEntry ? .lightGray : UIColor.AppColors.main.rawValue
    }
    
    @objc
    private func newPasswordShowPassword(_ sender: UIButton) {
        newPasswordTextField.isSecureTextEntry = !newPasswordTextField.isSecureTextEntry
        sender.tintColor = newPasswordTextField.isSecureTextEntry ? .lightGray : UIColor.AppColors.main.rawValue
    }
    
    @objc
    private func confirmPasswordShowPassword(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry = !confirmPasswordTextField.isSecureTextEntry
        sender.tintColor = confirmPasswordTextField.isSecureTextEntry ? .lightGray : UIColor.AppColors.main.rawValue
    }
    
    private func handleError(_ response: ChangePasswordErrorResponse) {
        if let old = response.oldPassword?.first {
            oldPasswordErrorLabel.text = old
            oldPasswordErrorWrapper.isHidden = false
        }
        
        if let new = response.newPassword?.first {
            newPasswordErrorLabel.text = new
            newPasswordErrorWrapper.isHidden = false
        }
    }
    
    private func clearFields() {
        oldPasswordErrorLabel.text = ""
        oldPasswordErrorWrapper.isHidden = true
        newPasswordErrorLabel.text = ""
        newPasswordErrorWrapper.isHidden = true
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " { return false }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, !nextField.isHidden {
            DispatchQueue.main.async {
                nextField.becomeFirstResponder()
            }
        } else {
            changePasswordButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}
