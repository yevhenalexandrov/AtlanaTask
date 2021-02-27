
import Foundation
import CoreData



extension User: ReadOnlyConvertible {
    
    func update(with item: GithubUserServerModel) {
        userID = item.userID
        userName = item.userName
        accountName = item.accountName
        avatarURL = item.avatarURL
        email = item.email
        bio = item.bio
        location = item.location
        createdAt = item.createdAt
        followersCount = item.followersCount
        followingCount = item.followingCount
        reposCount = item.reposCount
    }
    
    func toReadOnly() -> GithubUserServerModel {
        let repos = reposArray.map { $0.toReadOnly() }
        
        return GithubUserServerModel(userID: userID,
                                     accountName: accountName ?? "",
                                     userName: userName ?? "",
                                     avatarURL: avatarURL ?? "",
                                     email: email ?? "",
                                     bio: bio ?? "",
                                     location: location ?? "",
                                     createdAt: createdAt ?? "",
                                     followersCount: followersCount,
                                     followingCount: followingCount,
                                     reposCount: reposCount,
                                     repos: repos)
    }
}


extension User {
    var reposArray: [Repo] {
        repos?.toArray() ?? []
    }
}


extension GithubUserServerModel: ReadOnlyType {

    public func isReadOnlyRepresentation(of storageEntity: Any) -> Bool {
        guard let storageUser = storageEntity as? User else {
            return false
        }

        return userID == Int64(storageUser.userID) && (userName == storageUser.userName)
    }
}
