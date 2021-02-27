//
//  GithubRepo.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 26.02.2021.
//

import Foundation


struct GithubRepo: Decodable {
    
    var repositoryName: String
    var repoURL: String
    var starsCount: Int64
    var forksCount: Int64
    var ownerRepo: OwnerRepo
    
    private enum CodingKeys: String, CodingKey {
        case repositoryName = "name", repoURL = "html_url", forksCount = "forks_count", starsCount = "stargazers_count", owner = "owner"
    }
    
    /// User struct initializer.
    ///
    init(repositoryName: String,
         repoURL: String,
         starsCount: Int64,
         forksCount: Int64,
         ownerRepo: OwnerRepo)
    {
        self.repositoryName = repositoryName
        self.repoURL = repoURL
        self.starsCount = starsCount
        self.forksCount = forksCount
        self.ownerRepo = ownerRepo
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.repositoryName = container.failsafeDecodeIfPresent(stringForKey: .repositoryName) ?? ""
        self.repoURL = container.failsafeDecodeIfPresent(stringForKey: .repoURL) ?? ""
        self.starsCount = try container.decodeIfPresent(Int64.self, forKey: .starsCount) ?? 0
        self.forksCount = try container.decodeIfPresent(Int64.self, forKey: .forksCount) ?? 0
        self.ownerRepo = try container.decode(OwnerRepo.self, forKey: .owner)
    }
}


extension GithubRepo: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(repositoryName)
        hasher.combine(repoURL)
        hasher.combine(starsCount)
        hasher.combine(forksCount)
    }
    
    static func == (lhs: GithubRepo, rhs: GithubRepo) -> Bool {
        return lhs.repositoryName == rhs.repositoryName &&
            lhs.repoURL == rhs.repoURL &&
            lhs.starsCount == rhs.starsCount &&
            lhs.forksCount == rhs.forksCount
    }
}



struct OwnerRepo: Decodable {
    
    var userID: Int64
    var userName: String
    
    private enum CodingKeys: String, CodingKey {
        case userID = "id", userName = "login"
    }
    
    /// User struct initializer.
    ///
    init(userID: Int64,
         userName: String)
    {
        self.userID = userID
        self.userName = userName
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.userID = try container.decodeIfPresent(Int64.self, forKey: .userID) ?? 0
        self.userName = container.failsafeDecodeIfPresent(stringForKey: .userName) ?? ""
    }
}
