
import SwiftUI

struct PasswordRequirement: Identifiable {
    let id = UUID()
    let text: String
    var isMet: Bool
}

struct SignupView: View {
    @State private var isValidPassword = false
    @State private var showPasswordRequirements = true
    @State private var isConfirmPasswordValid = true
    @State private var passwordRequirements = [
        PasswordRequirement(text: "At least 1 number", isMet: false),
        PasswordRequirement(text: "At least 8 characters", isMet: false),
        PasswordRequirement(text: "At least 1 uppercase letter", isMet: false),
        PasswordRequirement(text: "At least 1 special character", isMet: false)
    ]
    
    @StateObject private var SignupVM = SignupViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Image("Standing1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                
                TextField("Email", text: $SignupVM.email)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)

                TextField("Fullname", text: $SignupVM.full_name)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                
                
                SecureField("Password", text: $SignupVM.password)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                    .onChange(of: SignupVM.password) { oldValue, newValue in
                        validatePassword(newValue)
                        
                        showPasswordRequirements = !passwordRequirements.allSatisfy { $0.isMet }
                        
                    }
                
                if showPasswordRequirements && !SignupVM.password.isEmpty {
                    VStack(alignment: .leading) {
                        ForEach(passwordRequirements) { requirement in
                            HStack {
                                Text(requirement.text)
                                    .foregroundStyle(requirement.isMet ? .green : .gray)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                
                SecureField("Confirm password", text: $SignupVM.password_confirmation)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                
            }
            .padding(.top, 60)
            .onChange(of: SignupVM.password_confirmation) { oldValue, newValue in
                validatePasswordConfirmation(newValue)
            }
            
            
            if !isConfirmPasswordValid {
                HStack {
                    Text("Your password does not matching")
                        .foregroundStyle(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack {
                Button {
                    if Validator.validatePassword(SignupVM.password) &&
                        SignupVM.password == SignupVM.password_confirmation {
                        SignupVM.signup()
                    } else {
                        isValidPassword = Validator.validatePassword(SignupVM.password)
                        isConfirmPasswordValid = SignupVM.password == SignupVM.password_confirmation
                    }
                } label: {
                    Text("Sign up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("SystemBlueLight"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                
            }
            
            
            .navigationDestination(isPresented: $SignupVM.isAuthenticated) {
                RemainderView(howMany: 3, startTime: Date(), endTime: Date().addingTimeInterval(3600), quotes: [
                    Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                ])
            }
            
        }
    }
    
    private func validatePassword(_ password: String) {
        for index in passwordRequirements.indices {
            switch passwordRequirements[index].text {
            case "At least 1 number":
                passwordRequirements[index].isMet = password.count >= 8
            case "At least 8 characters":
                passwordRequirements[index].isMet = password.rangeOfCharacter(from: .uppercaseLetters) != nil
            case "At least 1 uppercase letter":
                passwordRequirements[index].isMet = password.rangeOfCharacter(from: .decimalDigits) != nil
            case "At least 1 special character":
                passwordRequirements[index].isMet = password.rangeOfCharacter(from: CharacterSet(charactersIn: "@$!%*?&")) != nil
            default:
                break
            }
        }
        isValidPassword = passwordRequirements.allSatisfy { $0.isMet }
        
    }
    
    
    private func validatePasswordConfirmation(_ confirmation: String) {
        isConfirmPasswordValid = confirmation == SignupVM.password
    }
    
}

#Preview {
    SignupView()
}





