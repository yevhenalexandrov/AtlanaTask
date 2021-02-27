//
//  Repo+ReadOnlyConvertible.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 27.02.2021.
//

import Foundation
import CoreData


extension Repo: ReadOnlyConvertible {
    
    func update(with item: GithubRepo) {
        self.repositoryName = item.repositoryName
        self.repoURL = item.repoURL
        self.starsCount = item.starsCount
        self.forksCount = item.forksCount
        self.ownerID = item.ownerRepo.userID
        self.ownerName = item.ownerRepo.userName
    }
    
    func toReadOnly() -> GithubRepo {
        return GithubRepo(repositoryName: repositoryName,
                          repoURL: repoURL,
                          starsCount: starsCount,
                          forksCount: forksCount,
                          ownerRepo: OwnerRepo(userID: ownerID, userName: ownerName))
    }
}



extension GithubRepo: ReadOnlyType {

    public func isReadOnlyRepresentation(of storageEntity: Any) -> Bool {
        guard let storageUser = storageEntity as? Repo else {
            return false
        }

        return repositoryName == storageUser.repositoryName && (repoURL == storageUser.repoURL)
    }
}
