
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var profileImage: UIImage?
    
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
        
        
       let imageData = defaults.data(forKey: "user_profile_image")
            if let imageData = imageData {
            self.profileImage = UIImage(data: imageData)
        }
        
        self.user = UserProfile(fullName: fullName, email: email, photoUrl: "", imageData: imageData)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let updatedFullName = defaults.string(forKey: "user_fullname") ?? fullName
            let updatedEmail = defaults.string(forKey: "user_email") ?? email
            
            if updatedFullName != fullName || updatedEmail != email {
                self.user = UserProfile(fullName: updatedFullName, email: updatedEmail, photoUrl: "", imageData: self.user?.imageData)
            }
        }
        
    }
    func saveProfile(fullName: String, email: String) {
        UserDefaults.standard.setValue(fullName, forKey: "user_fullname")
        UserDefaults.standard.setValue(email, forKey: "user_email")
        UserDefaults.standard.synchronize()
        
        self.user = UserProfile(fullName: fullName, email: email, photoUrl: self.user?.photoUrl ?? "", imageData: self.user?.imageData)
    }
    func saveProfileImage(_ image: UIImage) {
          if let imageData = image.jpegData(compressionQuality: 0.8) {
              UserDefaults.standard.set(imageData, forKey: "user_profile_image")
              UserDefaults.standard.synchronize()
              
              self.profileImage = image
              
              if let user = self.user {
                  self.user = UserProfile(
                      fullName: user.fullName,
                      email: user.email,
                      photoUrl: user.photoUrl,
                      imageData: imageData
                  )
              }
          }
      }
}

struct UserProfile {
    var fullName: String
    var email: String
    var photoUrl: String
    var imageData: Data?
}

