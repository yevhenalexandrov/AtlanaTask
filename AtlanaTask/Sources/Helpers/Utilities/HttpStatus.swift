
import Foundation


struct HttpStatus {
    
    let code: Int
    
    var isOk: Bool {
        return (200..<300).contains(code)
    }
    
    public init(_ response: HTTPURLResponse) {
        code = response.statusCode
    }
    
    public init(_ code: Int) {
        self.code = code
    }
    
}
