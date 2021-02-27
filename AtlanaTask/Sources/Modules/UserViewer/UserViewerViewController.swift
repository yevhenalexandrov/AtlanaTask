
import UIKit
import RxSwift


class UserViewerViewController: UIViewController, Instantiatable {
    
    private enum RepoSection {
        case main
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var bioLabel: EdgeInsetLabel!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchBarTextView: PaddedTextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public Properties
    
    var viewModel: UserViewerViewModel!
    
    // MARK: - Private Properties
    
    private var repositories: [GithubRepo] = []
    
    private var userDetails: GithubUserServerModel? {
        return viewModel.dataSource.fetchedObject
    }
    
    private var diffableTableViewDataSource: UITableViewDiffableDataSource<RepoSection, GithubRepo>!
    
    private var dateFormatter = UserDateFormatter()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.dataSource.delegate = self
        viewModel.loadData()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        if let navigationView = self.navigationController {
            navigationView.navigationBar.tintColor = .black
            navigationView.removeShadow()
            setBackBarButtonName("")
        }
        
        setupSearchBar()
        setupTableView()
        setupBiographyView()
    }
    
    private func setupSearchBar() {
        searchBarTextView.placeholder = "Search for User's Repositories"
        searchBarTextView.clearButtonMode = .whileEditing
        searchBarTextView.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        searchBarTextView.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { searchTerm in
                guard let searchTerm = searchTerm else { return }
                
                let items = (!searchTerm.isEmpty) ? self.repositories.filter { $0.repositoryName.lowercased().contains(searchTerm) } : self.repositories
                
                self.buildAndApplySnapshot(for: items)
            })
            .disposed(by: disposeBag)

    }
    
    private func setupTableView() {
        tableView.register(cell: UserViewerRepoViewCell.self)
        tableView.delegate = self
        
        diffableTableViewDataSource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserViewerRepoViewCell.defaultReuseIdentifier,
                                                           for: indexPath) as? UserViewerRepoViewCell
            else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            return cell
        }
        
        diffableTableViewDataSource.defaultRowAnimation = .fade
    }
    
    private func setupBiographyView() {
        bioLabel.textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    private func buildAndApplySnapshot(for repos: [GithubRepo]) {
        var snapshot = NSDiffableDataSourceSnapshot<RepoSection, GithubRepo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(repos, toSection: .main)
        diffableTableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateUI() {
        guard let user = self.userDetails else {
            return
        }
        
        setNavigationItemTitle(user.accountName)
        
        updateText(for: userNameLabel, text: user.userName)
        updateText(for: emailLabel, text: user.email)
        updateText(for: locationLabel, text: user.location)
        updateCounter(for: followersLabel, count: user.followersCount, formattedString: "%ld Followers")
        updateCounter(for: followingLabel, count: user.followingCount, formattedString: "Following %ld")
        updateBio(with: user.bio)
        updateCreatedAtLabel(with: user.createdAt)
        
        if let url = URL(string: user.avatarURL) {
            userImageView.setImage(imageURL: url)
        }
    }
    
    private func updateBio(with bioString: String?) {
        self.bioLabel.text = bioString
    }
    
    private func updateText(for label: UILabel, text: String?) {
        label.isHidden = (text != nil) && (text!.isEmpty)
        label.fadeTransition(0.3)
        label.text = text
    }
    
    private func updateCounter(for label: UILabel, count: Int64, formattedString: String) {
        guard count > 0 else { return }
        label.isHidden = false
        let str = String(format: formattedString, count)
        label.fadeTransition(0.3)
        label.text = str
    }
    
    private func updateCreatedAtLabel(with dateString: String) {
        guard !dateString.isEmpty else { return }
        
        let date = Date(dateString: dateString)
        let dateFormattedString = dateFormatter.string(from: date)
        
        updateText(for: joinDateLabel, text: dateFormattedString)
    }
    
    private func didSelectItem(at indexPath: IndexPath) {
        guard let repo = diffableTableViewDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel
            .openLink(for: repo)
            .analyzeFailure(self.handleViewModelError(_:))
    }
    
    // MARK: - Error handlers
    
    private func handleViewModelError(_ error: UserViewerViewModel.Error) {
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


// MARK: - UserViewerDataSourceDelegate

extension UserViewerViewController: UserViewerDataSourceDelegate {
    
    func dataSourceDidFinishObtainUserData(_ dataSource: UserViewerDataSource) {
        self.repositories = self.userDetails?.repos ?? []
        updateUI()
    }
    
    func dataSource(_ dataSource: UserViewerDataSource, didFinishWithError error: GithubError) {
        showErrorAlert(message: error.stringDescription)
    }
}


// MARK: - UITableViewDelegate

extension UserViewerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectItem(at: indexPath)
    }
}

