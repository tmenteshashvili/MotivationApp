
import SwiftUI

enum NextStack {
    case forgotpassword
    case signup
}

enum FocusedField {
    case email
    case password
    case full_name
    case password_confirmation
}

struct LoginView: View {
    @State private var message: String = ""
    @State private var presentNextView = false
    @State private var nextView: NextStack = .signup
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    
    
    @FocusState private var focusedField: FocusedField?
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {
        
        NavigationStack {
            Spacer()
            VStack(spacing: 15) {
                Image("OnFloor1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 370)

                
                EmailTextField(title: "Email", errorText: "Your email in no valid")
                PasswordTextField(errorText: "Your password in not valid")
                
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
                    
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
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
                .padding(.bottom)
            }
            
                .navigationDestination(isPresented: $loginVM.isAuthenticated) {
                    RemainderView(howMany: 3, startTime: Date(), endTime: Date().addingTimeInterval(3600), quotes: [
                        Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                    ])
                }
        }
        
    }
    
}
#Preview {
    LoginView()
}
