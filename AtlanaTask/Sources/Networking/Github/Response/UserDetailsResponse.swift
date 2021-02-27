
import Foundation


struct UserDetailsResponse: Decodable {
    
    static func empty() -> Self {
        return UserDetailsResponse(user: nil)
    }
    
    var user: UserDetailsServerModel?
    
    init(user: UserDetailsServerModel?) {
        self.user = user
    }
    
    // MARK: - Init Decoder
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            self.user = try container.decode(UserDetailsServerModel.self)
        } catch DecodingError.keyNotFound {
            DebugLog("UserDetailsResponse keyNotFound!")
        }
    }
}
