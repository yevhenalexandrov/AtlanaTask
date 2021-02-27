
import Foundation


struct GithubUserListResponse: Decodable {
    
    static func empty() -> Self {
        return GithubUserListResponse(models: [])
    }
    
    var models: [GithubUserServerModel] = []
    
    private enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(models: [GithubUserServerModel]) {
        self.models = models
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.models = try container.decode([GithubUserServerModel].self, forKey: .items)
        } catch DecodingError.keyNotFound {
            DebugLog("GithubUserListResponse keyNotFound!")
        }
    }
}

