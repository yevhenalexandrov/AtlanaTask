
import Foundation


class UserViewerViewModel {
    
    enum Error: Swift.Error, Descriptable {
        case unableToOpenRepoUrl
        
        var stringDescription: String {
            switch self {
            case .unableToOpenRepoUrl:
                return "Unable to open repository link"
            }
        }
    }
    
    var user: GithubUserServerModel!
    
    let dataSource: UserViewerDataSource
    
    weak var output: UserViewerModuleOutput?
    
    // MARK: - Initializer
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.dataSource = UserViewerDataSource(networkService: networkService, storageService: storageService)
    }
    
    // MARK: - Public Methods
    
    func configure(for user: GithubUserServerModel) {
        self.user = user
    }
    
    func loadData() {
        dataSource.obtainUser(with: user)
    }
    
    func openLink(for itemModel: GithubRepo) -> Result<Void, UserViewerViewModel.Error> {
        if let repoURL = URL(string: itemModel.repoURL) {
            output?.openLink(repoURL)
            return .success(())
        } else {
            return .failure(.unableToOpenRepoUrl)
        }
    }
    
}

