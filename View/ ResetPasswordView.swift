import SwiftUI

struct passwordRequirement: Identifiable {
    let id = UUID()
    let text: String
    var isMet: Bool
}

struct ResetPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isValidPassword = false
    @State private var showPasswordRequirements = true
    @State private var isConfirmPasswordValid = true
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var passwordRequirements = [
        passwordRequirement(text: "At least 1 number", isMet: false),
        passwordRequirement(text: "At least 8 characters", isMet: false),
        passwordRequirement(text: "At least 1 uppercase letter", isMet: false),
        passwordRequirement(text: "At least 1 special character", isMet: false)
    ]
    

    let token: String
    let email: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.title)
                .bold()
            
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                }
                .textContentType(.newPassword)
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color("SystemBlueLight"))
                }
                .padding(.trailing, 8)
            }
            .padding()
            .background(Color("SystemBackgroundLightSecondary"))
            .cornerRadius(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("SystemBlueLight"), lineWidth: 3)
            )
            .padding(.horizontal)
            .onChange(of: viewModel.password) { oldValue, newValue in
                validatePassword(newValue)
                showPasswordRequirements = !passwordRequirements.allSatisfy { $0.isMet }
            }
            
            if showPasswordRequirements && !viewModel.password.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(passwordRequirements) { requirement in
                        HStack {
                            Image(systemName: requirement.isMet ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(requirement.isMet ? .green : .gray)
                            Text(requirement.text)
                                .foregroundStyle(requirement.isMet ? .green : .gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                Group {
                    if isConfirmPasswordVisible {
                        TextField("Confirm password", text: $viewModel.password_confirmation)
                    } else {
                        SecureField("Confirm password", text: $viewModel.password_confirmation)
                    }
                }
                .textContentType(.newPassword)
                
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color("SystemBlueLight"))
                }
                .padding(.trailing, 8)
            }
            .padding()
            .background(Color("SystemBackgroundLightSecondary"))
            .cornerRadius(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("SystemBlueLight"), lineWidth: 3)
            )
            .padding(.horizontal)
            .onChange(of: viewModel.password_confirmation) { oldValue, newValue in
                validatePasswordConfirmation(newValue)
            }
            
            if !isConfirmPasswordValid && !viewModel.password_confirmation.isEmpty {
                HStack {
                    Text("Passwords do not match")
                        .foregroundStyle(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
            
            Button("Reset Password") {
                viewModel.token = token
                viewModel.email = email
                viewModel.resetPassword()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                         dismiss()
                     }
                     .foregroundColor(.red)

        }
        .padding()
        .onAppear {
            print("Token: \(token), Email: \(email)")
        }
    }
    
    private func validatePassword(_ password: String) {
        passwordRequirements[0].isMet = password.rangeOfCharacter(from: .decimalDigits) != nil
        passwordRequirements[1].isMet = password.count >= 8
        passwordRequirements[2].isMet = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        passwordRequirements[3].isMet = password.rangeOfCharacter(from: CharacterSet(charactersIn: "@$!%*?&")) != nil
        
        isValidPassword = passwordRequirements.allSatisfy { $0.isMet }
        
    }
    
    
    private func validatePasswordConfirmation(_ confirmation: String) {
        isConfirmPasswordValid = !confirmation.isEmpty && confirmation == viewModel.password
    }
}


#Preview {
    ResetPasswordView(token: "", email: "")
}

