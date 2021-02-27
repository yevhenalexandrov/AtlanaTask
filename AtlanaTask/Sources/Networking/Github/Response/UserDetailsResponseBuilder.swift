
import Foundation


class UserDetailsResponseBuilder {
    
    private let data: Data
    
    private let decoder = JSONDecoder()
    
    init(data: Data) {
        self.data = data
    }
    
    func buildResult() -> Result<UserDetailsResponse, ParsingError> {
        do {
            guard let response = try? decoder.decode(UserDetailsResponse.self, from: data) else {
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

