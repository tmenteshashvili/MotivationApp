import SwiftUI

struct EditProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var fullName: String = ""
    @State private var email: String = ""

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
            .navigationBarItems(trailing: Button("Save") {
                saveProfile()
            })
            .onAppear {
                if let user = profileViewModel.user {
                    fullName = user.fullName
                    email = user.email
                }
            }
        }
    }
    
    private func saveProfile() {
        profileViewModel.user = UserProfile(fullName: fullName, email: email, photoUrl: profileViewModel.user?.photoUrl ?? "")
    }
}

#Preview {
    EditProfileView(profileViewModel: ProfileViewModel())
}

