
import UIKit
import RxSwift


class UserListViewController: UIViewController, Instantiatable {

    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var searchResultsContainer: UIView!
    @IBOutlet weak var searchTextField: PaddedTextField!
    
    // MARK: - Public properties
    
    weak var output: UserListModuleOutput?
    
    // MARK: - Private properties
    
    private var viewModel: UserListViewModel!
    
    private var searchResultsViewController: SearchResultsListViewController?
    
    private var users: PublishSubject<[GithubUserServerModel]> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inititalSetup()
    }
    
    // MARK: - Public methods
    
    func bind(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        
        self.viewModel.onDidChangeContent = { [weak self] users in
            guard let `self` = self else { return }
            self.users.onNext(users)
        }
    }
    
    // MARK: - Private Methods
    
    private func inititalSetup() {
        setupSearchBar()
        integrateResultsListContainer()
    }
    
    private func setupSearchBar() {
        searchTextField.placeholder = "Search for Users"
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        searchTextField.rx.text
            .orEmpty
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] searchTerm in
                guard let `self` = self else { return }
                self.didChangeSearchText(searchText: searchTerm)
            })
            .disposed(by: disposeBag)
    }
    
    private func integrateResultsListContainer() {
        let storyboard = UIStoryboard(name: "SearchResultsList", bundle: .main)
        let viewController = storyboard.instantiate() as SearchResultsListViewController
        
        self.searchResultsViewController = viewController
        self.searchResultsViewController?.delegate = self
        
        embed(viewController, into: searchResultsContainer)
        
        users
            .observe(on: MainScheduler.instance)
            .bind(to: viewController.usersSubject)
            .disposed(by: disposeBag)
    }
    
    private func searchUsers(text: String) {
        viewModel.searchUserList(searchTerm: text) { [weak self] result in
            guard let `self` = self else {
                return
            }
            switch result {
            case .success(let users):
                self.users.onNext(users)
            case .failure(let error):
                self.handleViewModelError(error)
            }
        }
    }
    
    func didChangeSearchText(searchText: String) {
        searchUsers(text: searchText)
    }
    
    // MARK: - Error handlers
    
    private func handleViewModelError(_ error: GithubError) {
        showErrorAlert(message: error.stringDescription)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension UserListViewController: SearchResultsListViewDelegate {
    
    func didSelectItem(user: GithubUserServerModel) {
        output?.showUserViewer(with: user)
    }
    
    func refreshUserList() {
        guard let searchTerm = searchTextField.text, !searchTerm.isEmpty else { return }
        didChangeSearchText(searchText: searchTerm)
    }
}
