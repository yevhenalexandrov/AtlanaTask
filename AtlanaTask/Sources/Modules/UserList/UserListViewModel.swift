
import Foundation
import CoreData


class UserListViewModel: NSObject {

    var githubService: GithubServiceProtocol
    
    var onDidChangeContent: (([GithubUserServerModel]) -> Void)?
    
    // MARK: - Private Properties
    
    private let storageService: StorageServiceProtocol
    
    /// User ResultsController.
    ///
    private lazy var userResultsController: RichFetchedResultsController<User> = {
        let fetchRequest = RichFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \User.userID, ascending: true)]

        let viewStorage = CoreDataManager.shared.viewStorage
        let controller = RichFetchedResultsController<User>(fetchRequest: fetchRequest,
                                                            managedObjectContext: viewStorage,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    var fetchedObjects: [GithubUserServerModel] {
        if let results = userResultsController.fetchedObjects, let users = results as? [User] {
            return users.map { $0.toReadOnly() }
        }
        return []
    }
    
    // MARK: - Initializer
    
    init(githubService: GithubServiceProtocol, storageService: StorageServiceProtocol) {
        self.githubService = githubService
        self.storageService = storageService
    }
    
    // MARK: - Public Methods
    
    func searchUserList(searchTerm: String?, completion: @escaping (Result<[GithubUserServerModel], GithubError>) -> Void) {
        guard let searchText = searchTerm, searchText.count > 0 else { return }
        
        let searchRequestComposer = SearchDetailsRequest(searchString: searchText)
        
        githubService.requestUserList(searchRequest: searchRequestComposer) { result in
            switch result {
            case .success(let response):
                let users = response.models
                self.storageService.update(readOnlyObjects: users)
                
                let ids = users.map { $0.userID }
                self.refreshUserListPredicate(userIDs: ids)
                
                self.fetchUsersDetails(for: users)
                
                completion(.success(users))
            case .failure(let error):
                DebugLog("Error: \(error.stringDescription)")
                completion(.failure(error))
            }
        }
    }
}


private extension UserListViewModel {
    
    func fetchUsersDetails(for users: [GithubUserServerModel]) {
        let names = users.map { $0.accountName }
        
        let tasks = names.map { userName in
            return Task { controller in
                self.githubService.obtaintUser(username: userName) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let response):
                        self.updateStoredUser(user: response.user)
                        controller.finish()
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        let repos = names.map { userName in
            return Task { controller in
                self.githubService.obtainUserRepos(for: userName) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let response):
                        self.updatStoredRepos(items: response.repos)
                        controller.finish()
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        let sequence = Task.sequence([
            .group(tasks),
            .group(repos)
        ])

        sequence.perform { outcome in
            if case .success = outcome {
//                DebugLog("Did successfully obtain user/repos list!")
            }
        }
    }
    
    func updateStoredUser(user: UserDetailsServerModel?) {
        guard let user = user else {
            return
        }
        
        self.storageService.update(readOnlyObject: user.toUserReadOnly())
    }
    
    func updatStoredRepos(items: [GithubRepo]) {
        guard items.count > 0 else { return }
        self.storageService.updateUserRepos(readOnlyObjects: items)
    }
    
    func refreshUserListPredicate(userIDs: [Int64]) {
        let userIDsPredicate = NSPredicate(format: "userID IN %@", userIDs)
        userResultsController.fetchRequest.predicate = userIDsPredicate
        try? userResultsController.performFetch()
    }
    
    func dataWasUpdated() {
        onDidChangeContent?(fetchedObjects)
    }
}


// MARK: - NSFetchedResultsControllerDelegate Methods

extension UserListViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataWasUpdated()
    }
}
