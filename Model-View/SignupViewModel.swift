
import Foundation


class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var full_name: String = ""
    @Published var password: String = ""
    @Published  var password_confirmation: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""
    @Published var showSuccessAlert: Bool = false
    
    
    func signup() {
        
        guard !email.isEmpty, !full_name.isEmpty, !password.isEmpty, !password_confirmation.isEmpty else {
            message = "All fields are required"
            return
        }
        
        guard password == password_confirmation else {
            message = "Passwords do not match"
            return
        }
        
        let defaults = UserDefaults.standard
        
        Webservice().signup(email: email, full_name: full_name, password: password, password_confirmation: password_confirmation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    defaults.setValue(token, forKey: "JWT")
                    defaults.setValue(self.email, forKey: "user_email")
                    defaults.setValue(self.full_name, forKey: "user_fullname")
                    defaults.setValue(true, forKey: "justAuthenticated")
                    
                    self.showSuccessAlert = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isAuthenticated = true
                        self.message = ""
                    }
                    
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
    
}
