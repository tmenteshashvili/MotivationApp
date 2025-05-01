
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    
    init() {
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        let defaults = UserDefaults.standard
        var fullName = defaults.string(forKey: "user_fullname") ?? "Unknown"
        var email = defaults.string(forKey: "user_email") ?? ""
        
        if fullName.isEmpty || email.isEmpty {
            if let token = defaults.string(forKey: "JWT"), !token.isEmpty {
                if email.isEmpty {
                    email = "Please enter your email"
                }
                if fullName.isEmpty {
                    fullName = "Please enter your name"
                }
            } else {
                fullName = "Unknown"
                email = "Unknown"
            }
        }
        
        self.user = UserProfile(fullName: fullName, email: email, photoUrl: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let updatedFullName = defaults.string(forKey: "user_fullname") ?? fullName
            let updatedEmail = defaults.string(forKey: "user_email") ?? email
            
            if updatedFullName != fullName || updatedEmail != email {
                self.user = UserProfile(fullName: updatedFullName, email: updatedEmail, photoUrl: "")
            }
        }
        
    }
    func saveProfile(fullName: String, email: String) {
        UserDefaults.standard.setValue(fullName, forKey: "user_fullname")
        UserDefaults.standard.setValue(email, forKey: "user_email")
        UserDefaults.standard.synchronize()
        
        self.user = UserProfile(fullName: fullName, email: email, photoUrl: self.user?.photoUrl ?? "")
    }
}

struct UserProfile {
    var fullName: String
    var email: String
    var photoUrl: String
}

