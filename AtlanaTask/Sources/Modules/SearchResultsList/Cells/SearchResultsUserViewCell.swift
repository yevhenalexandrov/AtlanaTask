
import UIKit


class SearchResultsUserViewCell: UITableViewCell, Reusable, Configurable, NibLoadableView {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var reposLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var user: GithubUserServerModel! {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: Configurable Methods
    
    func configure(with viewModel: GithubUserServerModel) {
        self.user = viewModel
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        reposLabel.text = ""
        usernameLabel.text = ""
    }
    
    private func updateUI() {
        guard let user = user else { return }
        self.usernameLabel.text = user.accountName
        
        updateRepoUI(count: user.reposCount)
        
        if let imageURL = URL(string: user.avatarURL) {
            self.avatarView.setImage(imageURL: imageURL)
        }
    }
    
    private func updateRepoUI(count: Int64) {
        self.reposLabel.text = (count > 0) ? "Repo: \(user.reposCount)" : ""
    }
}
