//
//  UserReposResponseBuilder.swift
//  AtlanaTask
//
//  Created by Yevhen Alexandrov on 26.02.2021.
//

import Foundation


class UserReposResponseBuilder {
    
    private let data: Data
    
    private let decoder = JSONDecoder()
    
    init(data: Data) {
        self.data = data
    }
    
    func buildResult() -> Result<UserReposResponse, ParsingError> {
        do {
            guard let response = try? decoder.decode(UserReposResponse.self, from: data) else {
                throw ParsingError.wrongType(key: "Root key")
            }
            
            return .success(response)
            
        } catch let error as ParsingError {
            return .failure(error)
        } catch {
            return .failure(.jsonParsingError(error: error))
        }
    }
}
