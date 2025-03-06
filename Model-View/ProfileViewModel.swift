
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    
    init() {
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        let defaults = UserDefaults.standard
        let fullName = defaults.string(forKey: "user_fullname") ?? "Unknown"
        let email = defaults.string(forKey: "user_email") ?? "Unknown"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = UserProfile(fullName: fullName, email: email, photoUrl: "")
        }
    }
    
}

struct UserProfile {
    var fullName: String
    var email: String
    var photoUrl: String
}

