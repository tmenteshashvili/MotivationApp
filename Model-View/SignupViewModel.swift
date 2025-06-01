
import Foundation


class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var full_name: String = ""
    @Published var password: String = ""
    @Published  var password_confirmation: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""
    @Published var showSuccessAlert: Bool = false
    @Published var isLoading: Bool = false
    
    
    func signup() {
        
        guard !email.isEmpty, !full_name.isEmpty, !password.isEmpty, !password_confirmation.isEmpty else {
            message = "All fields are required"
            return
        }
        
        guard password == password_confirmation else {
            message = "Passwords do not match"
            return
        }
        
        isLoading = true
        message = ""
        let defaults = UserDefaults.standard
        
        Webservice().signup(email: email, full_name: full_name, password: password, password_confirmation: password_confirmation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    defaults.setValue(self.email, forKey: "user_email")
                    defaults.setValue(self.full_name, forKey: "user_fullname")
                    defaults.setValue(true, forKey: "justAuthenticated")
                    
                    defaults.synchronize()
                    
                    self.autoLoginAfterSignup()
                    

                case .failure(let error):
                    self.isAuthenticated = false
                    switch error {
                    case .invalidCredentials:
                        self.message = "Sign up failed. Please check your information and try again."
                    case .custom(let errorMessage):
                        self.message = errorMessage
                    case .serverError(message: let message):
                        self.message = message
                    case .decodingError(message: let message):
                        self.message = message
                    }
                }
            }
        }
    }
    private func autoLoginAfterSignup() {
            Task {
                do {
                    let token = try await Webservice().login(email: self.email, password: self.password, client: "ios")
                    await MainActor.run {
                        let defaults = UserDefaults.standard
                        
                        defaults.setValue(token, forKey: "JWT")
                        defaults.setValue(true, forKey: "justAuthenticated")
                        
                        defaults.setValue(self.email, forKey: "user_email")
                        defaults.setValue(self.full_name, forKey: "user_fullname")
                        
                        defaults.synchronize()
                        
                        print("Auto-login successful, token saved")
                        print("Final UserDefaults - Email: \(defaults.string(forKey: "user_email") ?? "nil"), Name: \(defaults.string(forKey: "user_fullname") ?? "nil")")
                        
                        self.showSuccessAlert = true
                        self.isAuthenticated = true
                        self.message = ""
                        self.isLoading = false
                        
                        NotificationCenter.default.post(name: .userAuthenticated, object: nil)
                    }
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        self.message = "Account created but login failed. Please try logging in manually."
                        print("Auto-login failed: \(error)")
                    }
                }
            }
        }
}
