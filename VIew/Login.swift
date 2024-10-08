
import SwiftUI

enum NextStack {
    case forgotpassword
    case signup
    case remainder
}

struct Login: View {
    @AppStorage("isDarkMode") private var isDark = false
    @State private var message: String = ""
    @State private var presentNextView = false
    @State private var nextView: NextStack = .remainder
    
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()
                Image("OnFloor1")
                    .resizable()
                    .scaledToFit()
                
                
                TextField("Email", text: $loginVM.email)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                
                SecureField("Password", text: $loginVM.password)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                HStack {
                    Spacer()
                    
                    Button {
                        nextView = .forgotpassword
                        presentNextView.toggle()
                        
                    } label: {
                        Text("Forgot your password?")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.trailing)
                    .padding(.vertical)
                }
                
                Spacer()
                Spacer()
                
                Button {
                    loginVM.login()
                    
                } label: {
                    Text("Sign in")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color("Txtebackground"))
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("Logbuttondurk"))
                .cornerRadius(20)
                .padding(.horizontal)
                
            }
            
          
            Button {
                presentNextView.toggle()
                
            } label: {
                HStack {
                    Text("Don’t have an account? ")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.gray)
                    Text("Create Account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("Txtebackground"))
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Text(loginVM.message)
                .foregroundColor(.red)
                .padding()
            
        }
        
        .navigationDestination(isPresented: $loginVM.isAuthenticated) {
                Remainder( howMany: 3,
                           startTime: Date(),
                           endTime: Date().addingTimeInterval(3600),quotes:  [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")] )
            }

        .navigationTitle("login")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.colorScheme, isDark ? .dark : .light)
        
    }
}

#Preview {
    Login()
}
