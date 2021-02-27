

import Foundation
import CoreData


protocol UserViewerDataSourceDelegate: class {
    func dataSourceDidFinishObtainUserData(_ dataSource: UserViewerDataSource)
    func dataSource(_ dataSource: UserViewerDataSource, didFinishWithError error: GithubError)
}


class UserViewerDataSource: NSObject {
    
    weak var delegate: UserViewerDataSourceDelegate?
    
    private let githubService: GithubServiceProtocol
    
    private let storageService: StorageServiceProtocol
    
    // MARK: - Private Properties
    
    private lazy var storageManager = CoreDataManager.shared
    
    private lazy var sharedDerivedStorage: NSManagedObjectContext = {
        return CoreDataManager.shared.newDerivedStorage()
    }()
    
    /// User ResultsController.
    ///
    private lazy var userResultsController: RichFetchedResultsController<User> = {
        let fetchRequest = RichFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.userName, ascending: true)]

        let viewStorage = CoreDataManager.shared.viewStorage
        let controller = RichFetchedResultsController<User>(fetchRequest: fetchRequest,
                                                            managedObjectContext: viewStorage,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    var fetchedObject: GithubUserServerModel? {
        if let results = userResultsController.fetchedObjects?.first, let user = results as? User {
            return user.toReadOnly()

        }
        return nil
    }
    
    // MARK: - Lifecycle
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.githubService = GithubService(networkService: networkService)
        self.storageService = storageService
    }
    
    // MARK: - Public Methods
    
    func obtainUser(with user: GithubUserServerModel) {
        refreshPredicate(for: user.userID)
        prepareUser()
        updateUserRequest(for: user.accountName)
    }
    
    // MARK: - Private Methods
    
    private func prepareUser() {
        guard fetchedObject != nil else {
            return
        }
        
        self.delegate?.dataSourceDidFinishObtainUserData(self)
    }
    
    private func refreshPredicate(for userID: Int64) {
        let userPredicate = \User.userID == userID
        userResultsController.fetchRequest.predicate = userPredicate
        try? userResultsController.performFetch()
    }
    
    private func updateUserRequest(for userName: String) {
        githubService.obtaintUser(username: userName) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let response):
                self.storageService.updateUserDetails(readOnlyObject: response.user)
            case .failure(let error):
                self.delegate?.dataSource(self, didFinishWithError: error)
            }
        }
    }
    
    private func dataWasUpdated() {
        self.delegate?.dataSourceDidFinishObtainUserData(self)
    }
}


extension UserViewerDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataWasUpdated()
    }
}
