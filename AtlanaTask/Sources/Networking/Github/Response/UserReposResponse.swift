//
//  UserReposResponse.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 26.02.2021.
//

import Foundation


struct UserReposResponse: Decodable {
    
    static func empty() -> Self {
        return UserReposResponse(repos: [])
    }
    
    var repos: [GithubRepo] = []
    
    // MARK: - Initializer
    
    init(repos: [GithubRepo]) {
        self.repos = repos
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let items = try container.decode([GithubRepo].self)
            self.repos = items 
        } catch DecodingError.keyNotFound {
            DebugLog("UserReposResponse keyNotFound!")
        }
    }
}
