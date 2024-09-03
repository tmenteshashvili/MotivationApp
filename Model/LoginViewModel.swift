
import Foundation


class LoginViewModel: ObservableObject {
    var email: String = ""
    var password: String = ""
    var client: String = ""
    
    @Published var isAuthenticated: Bool = false
    
    func login() {
        
        let defaults = UserDefaults.standard
        
        Webservice().login(email: email, password: password, client: "ios") { result in
            switch result {
            case .success(let token):
                defaults.setValue(token, forKey: "JWT")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            }
        }
    }
}


