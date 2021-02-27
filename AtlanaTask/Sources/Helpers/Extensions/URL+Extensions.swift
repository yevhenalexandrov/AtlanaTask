
import Foundation


extension URL {
    
    func urlWith(query: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.query = query
        return components?.url
    }
    
}

