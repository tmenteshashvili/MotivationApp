import UIKit
import SwiftUI
import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var client: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""
    @Published var showSuccessAlert: Bool = false
    @Published var isLoading: Bool = false
    
    init() {
        checkAuthStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthenticated),
                                               name: .userAuthenticated, object: nil)
    }
    func checkAuthStatus() {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "JWT"), !token.isEmpty {
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    @objc private func userAuthenticated() {
        self.isAuthenticated = true
    }
    
    func login() {
        guard !isLoading else { return }
        isLoading = true
        message = ""
        
        Task {
            do {
                let token = try await Webservice().login(email: email, password: password, client: "ios")
                await MainActor.run {
                    let defaults = UserDefaults.standard
                    defaults.setValue(token, forKey: "JWT")
                    defaults.setValue(true, forKey: "justAuthenticated")
                    
                    if defaults.string(forKey: "user_email")?.isEmpty ?? true {
                        defaults.setValue(self.email, forKey: "user_email")
                    }
                    
                    if defaults.string(forKey: "user_full_name")?.isEmpty ?? true {
                        defaults.setValue(self.email, forKey: "user_full_name")
                    }
                    
                    defaults.synchronize()
                    
                    self.showSuccessAlert = true
                    self.isAuthenticated = true
                    self.message = ""
                    
                    NotificationCenter.default.post(name: .userAuthenticated, object: nil)
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.message = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.message = "An unexpected error occurred"
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    func signout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "JWT")
        defaults.removeObject(forKey: "user_email")
        defaults.removeObject(forKey: "user_fullname")
        defaults.removeObject(forKey: "user_profile_image")
        defaults.removeObject(forKey: "justAuthenticated")
        defaults.synchronize()
        
        
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



