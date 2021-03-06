
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let joinedQuizCell = "joinedQuizCell"

/// Provider to list joined quizzes.
public class JoinedQuizzesViewController: UIViewController {
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: JoinedQuizListViewModel
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.bounces = false
        return tv
    }()
    
    /// :nodoc:
    init(waiting: Bool) {
        viewModel = JoinedQuizListViewModel(waiting: waiting)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal Error")
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = viewModel.waiting ? "Waiting Quizzes" : "End Quizzes"
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: joinedQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        bindUI()
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>.init(configureCell: { [weak self] (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: joinedQuizCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            
            guard let strongSelf = self else { return cell }
            if !strongSelf.viewModel.waiting {
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
            }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
                return true
        })
        
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.failure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                switch error {
                case .apiMessage(let response):
                    self.showErrorAlert(message: response.message)
                case .api(let response):
                    self.showErrorAlert(message: response.errorDesc)
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Quiz.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                
                if !strongSelf.viewModel.waiting {
                    let viewController = MyAnswersViewController(quizID: item.id)
                    strongSelf.navigationController?.pushViewController(viewController, animated: true)
                }
                
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
}
