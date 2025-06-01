import SwiftUI

struct PasswordRequirement: Identifiable {
    let id = UUID()
    let text: String
    var isMet: Bool
}

struct SignupView: View {
    var quotes: [QuoteService.Quote]
    @State private var isValidPassword = false
    @State private var showPasswordRequirements = true
    @State private var isConfirmPasswordValid = true
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showSuccessAlert = false
    @State private var passwordRequirements = [
        PasswordRequirement(text: "At least 1 number", isMet: false),
        PasswordRequirement(text: "At least 8 characters", isMet: false),
        PasswordRequirement(text: "At least 1 uppercase letter", isMet: false),
        PasswordRequirement(text: "At least 1 special character", isMet: false)
    ]
    
    @StateObject private var signupVM = SignupViewModel()
    @EnvironmentObject private var loginVM: LoginViewModel
    
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Image("Standing1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                
                TextField("Email", text: $signupVM.email)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                
                TextField("Fullname", text: $signupVM.full_name)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                
                
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $signupVM.password)
                        } else {
                            SecureField("Password", text: $signupVM.password)
                            
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
                .onChange(of: signupVM.password) { oldValue, newValue in
                    validatePassword(newValue)
                    showPasswordRequirements = !passwordRequirements.allSatisfy { $0.isMet }
                }
                
                if showPasswordRequirements && !signupVM.password.isEmpty {
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
                            TextField("Confirm password", text: $signupVM.password_confirmation)
                        } else {
                            SecureField("Confirm password", text: $signupVM.password_confirmation)
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
                .onChange(of: signupVM.password_confirmation) { oldValue, newValue in
                    validatePasswordConfirmation(newValue)
                }
                
                if !isConfirmPasswordValid && !signupVM.password_confirmation.isEmpty {
                    HStack {
                        Text("Passwords do not match")
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Spacer()
                    }
                }
                if !signupVM.message.isEmpty {
                    Text(signupVM.message)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button {
                    if isValidPassword && isConfirmPasswordValid {
                        signupVM.signup()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if signupVM.isAuthenticated {
                                showSuccessAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSuccessAlert = false
                                }
                            }
                        }
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
                .alert("Registration Successful", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your account has been created successfully!")
                }
                
                
                .navigationTitle("Create Account")
                .navigationDestination(isPresented: $signupVM.isAuthenticated) {
                    RemainderView(howMany: 3, quotes: [
                        QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                    ])
                }
                .navigationBarBackButtonHidden(true)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
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
        isConfirmPasswordValid = !confirmation.isEmpty && confirmation == signupVM.password
    }
}

#Preview {
    SignupView(quotes: [
        QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
    ])
}

struct FormField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var showPassword: Binding<Bool>? = nil
    
    var body: some View {
        HStack {
            Group {
                if isSecure {
                    if showPassword?.wrappedValue ?? false {
                        TextField(title, text: $text)
                    } else {
                        SecureField(title, text: $text)
                    }
                } else {
                    TextField(title, text: $text)
                }
            }
            .textContentType(isSecure ? .password : .none)
            
            if isSecure, let showPassword = showPassword {
                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}





