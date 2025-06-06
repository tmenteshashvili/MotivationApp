import Foundation

let USER_AUTH_TOKEN = "USER_AUTH"

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
    case serverError(message: String)
    case decodingError(message: String)
}

struct LoginRequestBody: Codable {
    let email: String
    let password: String
    let client: String
}

struct SignupRequestBody: Codable {
    let email: String
    let full_name: String
    let password: String
    let password_confirmation: String
}

struct RecoverPasswordRequestBody: Codable {
    let email: String
}

struct ResetPasswordRequestBody: Codable {
    let email: String
    let token: String
    let password: String
    let password_confirmation: String
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct RegisterResponse: Codable {
    let user: User
    
    struct User: Codable {
        let id: Int
        let email: String
        let full_name: String
        let created_at: String
        let updated_at: String
        let plans: [String]
    }
}

struct User: Codable {
    let id: Int
    let email: String
    let full_name: String
    let email_verified_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case full_name
        case email_verified_at
    }
}

struct RecoverResponse: Codable {
    let message: String
}

class Webservice {
    private let baseURL = "https://motivation.kakhoshvili.com/api/auth"
    
    enum NetworkError: Error {
        case invalidCredentials
        case serverError(message: String)
        case decodingError(message: String)
        case custom(String)
    }
    
    // MARK: - Login
    func login(email: String, password: String, client: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NetworkError.custom("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = [
            "email": email,
            "password": password,
            "client": client
        ]
        
        request.httpBody = try? JSONEncoder().encode(loginData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(message: "Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            struct LoginResponse: Codable {
                let token: String
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                return loginResponse.token
            } catch {
                throw NetworkError.decodingError(message: "Failed to decode token")
            }
            
        case 401:
            throw NetworkError.invalidCredentials
            
        default:
            throw NetworkError.serverError(message: "Server returned status code \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Signup
    func signup(email: String, full_name: String, password: String, password_confirmation: String, completion: @escaping(Result<String, AuthenticationError>) -> Void) {
        let endpoint = "\(baseURL)/register"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.custom(errorMessage: "Invalid URL")))
            return
        }
        
        let body = SignupRequestBody(
            email: email,
            full_name: full_name,
            password: password,
            password_confirmation: password_confirmation
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")  // Added Accept header
        
        
        if let jsonData = try? JSONEncoder().encode(body),
           let _ = String(data: jsonData, encoding: .utf8) {
            
        }
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            if let error = error {
                completion(.failure(.custom(errorMessage: "Network error: \(error.localizedDescription)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.custom(errorMessage: "No data received from server")))
                return
            }
            
            do {
                let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                completion(.success(String(registerResponse.user.id)))
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    if responseString.contains("<") {
                        print("Server returned HTML: \(responseString)")
                        completion(.failure(.custom(errorMessage: "Server returned HTML instead of JSON. The API endpoint might be incorrect.")))
                    } else {
                        do {
                            let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                            let errorMessage = errorResponse.values.first ?? "Unknown error"
                            completion(.failure(.custom(errorMessage: errorMessage)))
                        } catch {
                            completion(.failure(.custom(errorMessage: "Failed to decode server response")))
                        }
                    }
                }
            }
        }.resume()
    }
    
    
    // MARK: - Recover Password
    func recoverPassword(email: String, completion: @escaping(Result<String, AuthenticationError>) -> Void) {
        let endpoint = "\(baseURL)/request-recovery"
        
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.custom(errorMessage: "Invalid URL")))
            return
        }
        
        let body = RecoverPasswordRequestBody(email: email)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.custom(errorMessage: "Failed to encode request body")))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.custom(errorMessage: "Network error: \(error.localizedDescription)")))
                return
            }
            
            
            guard let data = data else {
                completion(.failure(.custom(errorMessage: "No data received from server")))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Password Recovery Raw Response: \(responseString)")
            }
            
            do {
                let recoverResponse = try JSONDecoder().decode(RecoverResponse.self, from: data)
                completion(.success(recoverResponse.message))
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    if responseString.contains("<") {
                        completion(.failure(.custom(errorMessage: "Server returned HTML instead of JSON. The API endpoint might be incorrect.")))
                    } else {
                        do {
                            let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                            let errorMessage = errorResponse.values.first ?? "Unknown error"
                            completion(.failure(.custom(errorMessage: errorMessage)))
                        } catch {
                            completion(.failure(.custom(errorMessage: "Failed to decode server response: \(error.localizedDescription)")))
                        }
                    }
                } else {
                    completion(.failure(.custom(errorMessage: "Invalid response format")))
                }
            }
        }.resume()
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String, token: String, password: String, password_confirmation: String, completion: @escaping(Result<String, AuthenticationError>) -> Void) {
        let endpoint = "\(baseURL)/reset-password"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.custom(errorMessage: "Invalid URL")))
            return
        }
        
        let body = ResetPasswordRequestBody(email: email, token: token, password: password, password_confirmation: password_confirmation)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.custom(errorMessage: "Failed to encode request body")))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.custom(errorMessage: "Network error: \(error.localizedDescription)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.custom(errorMessage: "No data received from server")))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Reset Password Raw Response: \(responseString)")
            }
            
            do {
                let recoverResponse = try JSONDecoder().decode(RecoverResponse.self, from: data)
                completion(.success(recoverResponse.message))
            } catch {
                completion(.failure(.custom(errorMessage: "Failed to decode server response: \(error.localizedDescription)")))
            }
        }.resume()
    }
}
    
