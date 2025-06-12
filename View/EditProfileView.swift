import SwiftUI

struct EditProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarBackButtonHidden(true)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        showSuccessAlert = true
                    }
                }
            }
            .onAppear {
                if let user = profileViewModel.user {
                    fullName = user.fullName
                    email = user.email
                } else {
                    profileViewModel.fetchUserProfile()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        if let user = profileViewModel.user {
                            fullName = user.fullName
                            email = user.email
                        }
                    }
                }
            }
            .alert("Profile Update", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully.")
            }
        }
    }
    
    private func saveProfile() {
        profileViewModel.saveProfile(fullName: fullName, email: email)
    }
}

#Preview {
    EditProfileView(profileViewModel: ProfileViewModel())
}

