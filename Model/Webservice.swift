
import Foundation

let USER_AUTH_TOKEN = "USER_AUTH"

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

struct LoginRequestBody: Codable {
    let email: String
    let password: String
    let client: String
}

struct AuthenticationRespons: Codable {
    let token: String?
    let user: User
}

struct User: Codable {
    let id: Int
    let fullName: String
    let email: String
    let emailVerifiedAt: String?
    let passwordConfirmation: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case emailVerifiedAt = "email_verified_at"
        case passwordConfirmation = "password_confirmation"
    }
}

struct SignupRequestBody: Codable {
    let email: String
    let full_name: String
    let password: String
    let password_confirmation: String
}


//struct SignupResponse: Codable {
//    let token: String?
//    let message: String
//    let user: User
//}

class Webservice {
    
    func login(email: String, password: String, client: String, completion: @escaping(Result<String, AuthenticationError>) -> Void ) {
        
        guard let url = URL(string: "https://motivation.kakhoshvili.com/api/auth/login") else { completion(.failure(.custom(errorMessage: "URL is not corect")))
            return
        }
        
        let body = LoginRequestBody(email: email, password: password, client: client)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "no data")))
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(AuthenticationRespons.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            UserDefaults.standard.setValue(loginResponse.token, forKey: USER_AUTH_TOKEN)
            
            guard let token = loginResponse.token else {
                completion(.failure(.invalidCredentials))
                return
            }
            completion(.success(token))
            
        } .resume()
 
    }
    
    
    func signup(email: String, full_name: String, password: String, password_confirmation: String,  completion: @escaping(Result<String, AuthenticationError>) -> Void ) {
        
        guard let url = URL(string: "https://motivation.kakhoshvili.com/api/auth/register") else { completion(.failure(.custom(errorMessage: "URL is not corect")))
            return
        }
        
        let body = SignupRequestBody(email: email, full_name: full_name, password: password, password_confirmation: password_confirmation)

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
      
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "no data")))
                return
            }
            
            guard let LoginResponse = try? JSONDecoder().decode(AuthenticationRespons.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            UserDefaults.standard.setValue(LoginResponse.token, forKey: USER_AUTH_TOKEN)

            
            guard let token = LoginResponse.token else {
                completion(.failure(.invalidCredentials))
                return
            }
            completion(.success(token))
            
        } .resume()
 
    }
    
}
