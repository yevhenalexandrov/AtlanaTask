
import Foundation
import CoreData


protocol StorageServiceProtocol {
    
    func update(readOnlyObject: GithubUserServerModel?)
    func update(readOnlyObjects: [GithubUserServerModel])
    func updateUserDetails(readOnlyObject: UserDetailsServerModel?)
    func updateUserRepos(readOnlyObjects: [GithubRepo])
}


class StorageService: StorageServiceProtocol {
    
    private lazy var storageManager = CoreDataManager.shared
    
    private lazy var sharedDerivedStorage: NSManagedObjectContext = {
        return CoreDataManager.shared.newDerivedStorage()
    }()
    
    // MARK: - Public Methods
    
    func update(readOnlyObjects: [GithubUserServerModel]) {
        readOnlyObjects.forEach { user in
            self.upsertStoredUser(readOnlyUser: user)
        }
    }
    
    func update(readOnlyObject: GithubUserServerModel?) {
        upsertStoredUser(readOnlyUser: readOnlyObject)
    }
    
    func updateUserDetails(readOnlyObject: UserDetailsServerModel?) {
        guard let readOnlyObject = readOnlyObject else { return }
        let user = readOnlyObject.toUserReadOnly()
        upsertStoredUser(readOnlyUser: user)
    }
    
    func updateUserRepos(readOnlyObjects: [GithubRepo]) {
        upsertStoredRepos(readOnlyUserRepos: readOnlyObjects)
    }
}


/// User
///
private extension StorageService {
    
    func upsertStoredUser(readOnlyUser: GithubUserServerModel?) {
        guard let readOnlyUser = readOnlyUser else { return }
        upsertStoredUserInBackground(readOnlyUser: readOnlyUser, onCompletion: {})
    }
    
    func upsertStoredUserInBackground(readOnlyUser: GithubUserServerModel, onCompletion: @escaping () -> Void) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform {
            self.upsertStoredUser(readOnlyUser: readOnlyUser, in: derivedStorage)
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }
    
    func upsertStoredUser(readOnlyUser: GithubUserServerModel, in storage: NSManagedObjectContext) {
        let storageUser = storage.loadUser(userID: readOnlyUser.userID) ?? storage.insertNewObject(ofType: User.self)
        storageUser.update(with: readOnlyUser)
        
        storage.saveIfNeeded()
    }
}


/// Repos
///
private extension StorageService {
    
    func upsertStoredRepos(readOnlyUserRepos: [GithubRepo]) {
        upsertStoredReposInBackground(readOnlyUserRepos: readOnlyUserRepos, onCompletion: {})
    }

    func upsertStoredReposInBackground(readOnlyUserRepos: [GithubRepo], onCompletion: @escaping () -> Void) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform {
            self.upsertStoredRepos(readOnlyUserRepos: readOnlyUserRepos, in: derivedStorage)
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }

    func upsertStoredRepos(readOnlyUserRepos: [GithubRepo], in storage: NSManagedObjectContext) {
        guard readOnlyUserRepos.count > 0 else { return }
        let userID = readOnlyUserRepos.first?.ownerRepo.userID ?? 0
        
        if let storageUser = storage.loadUser(userID: userID) {
            handleUserRepos(readOnlyUserRepos, storageUser, storage)
        }

        storage.saveIfNeeded()
    }

    func handleUserRepos(_ readOnlyRepos: [GithubRepo], _ storageUser: User, _ storage: NSManagedObjectContext) {
        // Remove all repos first
        storageUser.reposArray.forEach { existingStorageRepo in
            storage.deleteObject(existingStorageRepo)
        }
        
        // Insert the repos from read-only Repo
        var storageRepos = [Repo]()
        for repo in readOnlyRepos {
            let newStorageRepo = storage.insertNewObject(ofType: Repo.self)
            newStorageRepo.update(with: repo)
            storageRepos.append(newStorageRepo)
        }
        storageUser.repos = NSOrderedSet(array: storageRepos)
    }
}
