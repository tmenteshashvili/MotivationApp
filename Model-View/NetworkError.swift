import Foundation


enum NetworkError: Error {
    case invalidCredentials
    case serverError(message: String)
    case decodingError(message: String)
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Data error: \(message)"
        case .custom(let message):
            return message
        }
    }
}
