
import UIKit
import RxSwift
import RxCocoa


protocol SearchResultsListViewDelegate: class {
    
    func didSelectItem(user: GithubUserServerModel)
    func refreshUserList()
}


class SearchResultsListViewController: UIViewController, Instantiatable, KeyboardObserving, UIScrollViewDelegate {
    
    private enum Section: CaseIterable {
        case users
    }

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public Properties
    
    weak var delegate: SearchResultsListViewDelegate?
    
    // MARK: - Private Properties
    
    public var usersSubject = PublishSubject<[GithubUserServerModel]>()
    
    public var users: [GithubUserServerModel] = [] {
        didSet {
            checkForEmptyState()
            buildAndApplySnapshot()
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private var diffableTableViewDataSource: UITableViewDiffableDataSource<Section, GithubUserServerModel>!
    
    private var didSetupView = false
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
        registerForKeyboardEvents()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        setBackBarButtonName("")
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        
        tableView.register(cell: SearchResultsUserViewCell.self)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        usersSubject
            .subscribe(onNext: { [weak self] items in
                guard let `self` = self else { return }
                self.users = items
            }).disposed(by: disposeBag)
        
        diffableTableViewDataSource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultsUserViewCell.defaultReuseIdentifier,
                    for: indexPath) as? SearchResultsUserViewCell
            else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            return cell
        }
        
        diffableTableViewDataSource.defaultRowAnimation = .fade
    }
    
    private func buildAndApplySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GithubUserServerModel>()
        snapshot.appendSections([.users])
        snapshot.appendItems(users, toSection: .users)
        diffableTableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func checkForEmptyState() {
        (users.count > 0) ? tableView.restore() : tableView.setEmptyView(title: "Your search result is empty", message: "Your search result will be here")
    }
    
    private func didSelectItem(user: GithubUserServerModel) {
        guard let delegate = delegate else { return }
        delegate.didSelectItem(user: user)
    }

    // MARK: - Actions
    
    @objc private func pullToRefresh() {
        refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.delegate?.refreshUserList()
        }
    }
}


extension SearchResultsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let delegate = delegate, let user = diffableTableViewDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        delegate.didSelectItem(user: user)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: - KeyboardControllable

extension SearchResultsListViewController: KeyboardControllable {

    func keyboardWillShow(_ notification: Notification) {
        guard isVisible, let keyboardSize = notification.keyboardSize else { return }

        let keyboardHeight = keyboardSize.height > 100 ? keyboardSize.height : 0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }

    func keyboardWillHide(_ notification: Notification) {
        guard isVisible else { return }
            
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
