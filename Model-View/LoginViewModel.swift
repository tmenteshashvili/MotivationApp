import UIKit
import SwiftUI
import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var client: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""
    
    func login() {
 
        let defaults = UserDefaults.standard
        
        Webservice().login(email: email, password: password, client: "ios") { result in
            switch result {
            case .success(let token):
                defaults.setValue(token, forKey: "JWT")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.message = ""
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    switch error {
                    case .invalidCredentials:
                        self.message = "Invalid email or password"
                    case .custom(let errorMessage):
                        self.message = errorMessage
                    case .serverError(message: _):
                        self.isAuthenticated =  false
                    case .decodingError(message: _): break
                        
                    }
                }
            }
        }
    }
    func signout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "JWT")

        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
            self.message = ""

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: Welcome().environmentObject(self))
                window.makeKeyAndVisible()
            }
        }
    }
 }



