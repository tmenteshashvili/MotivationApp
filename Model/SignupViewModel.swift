
import Foundation


class SignupViewModel: ObservableObject {
    var email: String = ""
    var full_name: String = ""
    var password: String = ""
    var password_confirmation: String = ""
    var message: String = ""
    
    
    func signup() {
                
        let defaults = UserDefaults.standard
        
        Webservice().signup(email: email, full_name: full_name, password: password, password_confirmation: password_confirmation) { result in
            switch result {
            case .success(let token):
                defaults.setValue(token, forKey: "JWT")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

