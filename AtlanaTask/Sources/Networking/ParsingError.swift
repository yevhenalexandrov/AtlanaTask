

enum ParsingError: Error, Descriptable {
    
    case missingValue(key: String)
    case wrongType(key: String)
    case jsonParsingError(error: Error)
    
    var stringDescription: String {
        switch self {
        case .missingValue(let key):
            return "Missing value for key \(key)"
        case .wrongType(let key):
            return "Wrong type for key \(key)"
        case .jsonParsingError(let error):
            return "JSON parsing error: \(error.localizedDescription)"
        }
    }
    
}
