import SwiftUI
import Combine

enum NextStack {
    case forgotpassword
    case signup
}

struct LoginView: View {
    @EnvironmentObject private var loginVM: LoginViewModel
    var quotes: [QuoteService.Quote]
    @State private var message: String = ""
    @State private var presentNextView = false
    @State private var nextView: NextStack = .signup
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showSuccessAlert = false
    
    
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
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
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
                
                .padding(.top, 20)
                
                Spacer()
                
                Text(loginVM.message)
                    .foregroundColor(.red)
                    .padding()
                
                
                Button {
                    guard !loginVM.isLoading else { return }
                    loginVM.login()
                } label: {
                    HStack {
                        if loginVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                                .padding(.trailing, 8)
                        }
                        
                        Text("Sign in")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                }
                .disabled(loginVM.isLoading)
                .buttonStyle(PlainButtonStyle())
                .background(loginVM.isLoading ? Color("SystemBlueLight").opacity(0.7) : Color("SystemBlueLight"))
                .cornerRadius(20)
                .padding(.horizontal)
                .alert("Login Successful", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Welcome back!")
                }
                
                NavigationLink(destination: SignupView(quotes: [
                    QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                ])) {
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
            .navigationDestination(isPresented: $loginVM.isAuthenticated) {
                RemainderView(howMany: 3, quotes: [
                    QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                ])
            }
            .navigationBarBackButtonHidden(true)
            .modifier(DismissKeyboardOnTap())
        }
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                             to: nil, from: nil, for: nil)
            }
    }
}

#Preview {
    LoginView(quotes:[
        QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
    ])
}
