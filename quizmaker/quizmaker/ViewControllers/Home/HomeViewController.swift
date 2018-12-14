
import UIKit

/// :nodoc:
public class HomeViewController: UIViewController {
    
    let createQuizButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Quiz", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    let showMyQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Created Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    let lastStackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.axis = .horizontal
        sv.spacing = 10
        return sv
    }()
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showMyQuizzesButton.roundCorners(.allCorners, radius: 5)
        editProfileButton.roundCorners(.allCorners, radius: 5)
        createQuizButton.roundCorners(.allCorners, radius: 5)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    public func setupViews() {
        self.navigationItem.title = "Home"
        let logoutBarButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(logoutTapped(_:)))
        self.navigationItem.setRightBarButton(logoutBarButton, animated: false)
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        let stackView = UIStackView(arrangedSubviews: [createQuizButton, showMyQuizzesButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.setAnchors(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
        editProfileButton.addTarget(self, action: #selector(editProfileTapped(_:)), for: .touchUpInside)
        
        showMyQuizzesButton.addTarget(self, action: #selector(showMyQuizzesTapped(_:)), for: .touchUpInside)
        
        createQuizButton.addTarget(self, action: #selector(createQuizTapped(_:)), for: .touchUpInside)
    }
    
    @objc
    func logoutTapped(_ sender: UIBarButtonItem) {
        UserDefaults.standard.logout()
        self.present(LoginViewController(), animated: false, completion: nil)
    }
    
    @objc
    func editProfileTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
    }
    
    @objc
    func showMyQuizzesTapped(_ sender: UIButton) {
        let viewController = MyQuizListViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func createQuizTapped(_ sender: UIButton) {
        let viewController = QuizCreateViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
