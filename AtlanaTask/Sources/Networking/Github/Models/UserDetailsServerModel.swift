
import Foundation


struct UserDetailsServerModel: Decodable {
    
    var userID: Int64
    var accountName: String
    var userName: String
    var email: String?
    var bio: String?
    var createdAt: String
    var location: String?
    var followersCount: Int64
    var followingCount: Int64
    var publicReposCount: Int64
    var avatarURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case userName = "name", accountName = "login", email, location, bio, createdAt = "created_at", followersCount = "followers", followingCount = "following", publicReposCount = "public_repos", avatarURL = "avatar_url", userID = "id"
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.userID = try container.decode(Int64.self, forKey: .userID)
        self.userName = container.failsafeDecodeIfPresent(stringForKey: .userName) ?? ""
        self.accountName = container.failsafeDecodeIfPresent(stringForKey: .accountName) ?? ""
        self.email = container.failsafeDecodeIfPresent(stringForKey: .email)
        self.bio = container.failsafeDecodeIfPresent(stringForKey: .bio)
        self.createdAt = container.failsafeDecodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.location = container.failsafeDecodeIfPresent(stringForKey: .location)
        self.followersCount = try container.decodeIfPresent(Int64.self, forKey: .followersCount) ?? 0
        self.followingCount = try container.decodeIfPresent(Int64.self, forKey: .followingCount) ?? 0
        self.publicReposCount = try container.decodeIfPresent(Int64.self, forKey: .publicReposCount) ?? 0
        self.avatarURL = container.failsafeDecodeIfPresent(String.self, forKey: .avatarURL)
    }
    
    // MARK: - Private Methods
    
    private func decodeCreatedAtDate(dateString: String?) -> Date? {
        return (dateString != nil) ? Date(dateString: dateString!) : Date()
    }
    
    private func decodeURL(urlString: String?) -> URL? {
        return (urlString != nil) ? URL(string: urlString!) : nil
    }
    
}



extension UserDetailsServerModel {
    
    func toUserReadOnly() -> GithubUserServerModel {
        let user = GithubUserServerModel(userID: userID,
                                         accountName: accountName,
                                         userName: userName,
                                         avatarURL: avatarURL ?? "",
                                         email: email ?? "",
                                         bio: bio ?? "",
                                         location: location ?? "",
                                         createdAt: createdAt,
                                         followersCount: followersCount,
                                         followingCount: followingCount,
                                         reposCount: publicReposCount,
                                         repos: [])
        return user
    }
}
