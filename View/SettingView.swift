
import SwiftUI
import PhotosUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var profileViewModel = ProfileViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingEditProfile = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
            ScrollView {
                profileHeader
                
                
                accountManagementSection

                VStack(alignment: .leading, spacing: 12) {
                    SettingsRow(imageName: "bell", title: "Notifications", showRemainder: $settingsViewModel.showRemainder)
                        .sheet(isPresented: $settingsViewModel.showRemainder) {
                            NotificationSettingsView(howMany: $settingsViewModel.howMany,
                                                     startTime: $settingsViewModel.startTime,
                                                     endTime: $settingsViewModel.endTime,
                                                     notificationService: notificationService)
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground)))
                .padding(.top, 6)
                .padding(.horizontal)

            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(profileViewModel: profileViewModel)
        }
    }
    
    private var profileHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { showImagePicker.toggle() }) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        defaultProfileImage
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileViewModel.user?.fullName ?? "Loading...")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(profileViewModel.user?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private var defaultProfileImage: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            )
    }

    private var accountManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
               Text("Account Management")
                   .font(.headline)
                   .foregroundColor(.gray)
                   .padding(.horizontal)

               NavigationLink(destination: EditProfileView(profileViewModel: profileViewModel)) {
                   HStack {
                       Image(systemName: "person.circle")
                           .foregroundColor(.primary)
                       Text("Edit Profile")
                           .foregroundStyle(.primary)
                       Spacer()
                       Image(systemName: "chevron.right")
                           .font(.system(size: 16, weight: .regular, design: .rounded))
                           .foregroundColor(.primary)
                   }
                   .padding()
               }
               .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                   .fill(Color(.secondarySystemBackground)))
               .padding(.top, 6)
               .padding(.horizontal)

            Button(action: { loginViewModel.signout() }) {
                   HStack {
                       Image(systemName: "arrow.backward.circle")
                           .foregroundColor(.primary)
                       Text("Sing Out")
                           .foregroundColor(.primary)
                       Spacer()
                   }
                   .padding()
               }
               .background(Color(.secondarySystemBackground))
               .cornerRadius(10)
               .padding(.horizontal)
           }
           .padding(.top, 10)
    }
    
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let selectedImage = info[.originalImage] as? UIImage {
                    parent.image = selectedImage
                }
                picker.dismiss(animated: true)
            }
        }

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .photoLibrary
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    }
}

#Preview {
    SettingView()
}
