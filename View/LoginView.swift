
import SwiftUI
import Combine

enum NextStack {
    case forgotpassword
    case signup
}

struct LoginView: View {
    @State private var message: String = ""
    @State private var presentNextView = false
    @State private var nextView: NextStack = .signup
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    @StateObject private var loginVM = LoginViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Image("OnFloor1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .padding(.top)
                
                TextField("Email", text: $loginVM.email)
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                    .onChange(of: loginVM.email) { oldValue, newValue in
                        isValidEmail = Validator.validateEmail(newValue)
                    }
                if !isValidEmail {
                    HStack {
                        Text("Your email in not valid")
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Spacer()
                    }
                }
                
                
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $loginVM.password)
                        } else {
                            SecureField("Password", text: $loginVM.password)
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
                .onChange(of: loginVM.password) { oldValue, newValue in
                    isValidPassword = Validator.validatePassword(newValue)
                }
                
                if !isValidPassword {
                    HStack {
                        Text("Your password in not valid")
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Spacer()
                    }
                    
                }
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: RecoverPasswordView()) {
                        Text("Forgot your password?")
                            .foregroundStyle(.gray)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.trailing)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            Text(loginVM.message)
                .foregroundColor(.red)
                .padding()
            
            
            VStack(spacing: 12) {
                Button {
                    loginVM.login()
                } label: {
                    Text("Sign in")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    
                }
                .background(Color("SystemBlueLight"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                
                NavigationLink(destination: SignupView()) {
                    HStack {
                        Text("Don't have an account? ")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.gray)
                        Text("Create Account")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color("SystemBlueLight"))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom,8)
            
        }
        .navigationDestination(isPresented: $loginVM.isAuthenticated) {
            RemainderView(howMany: 3, quotes: [
                Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
            ])
        }
    }
    
}

#Preview {
    LoginView()
}
