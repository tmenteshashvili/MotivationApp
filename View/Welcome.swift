import SwiftUI


enum ViewStack {
    case login
    case signup
}

struct Welcome: View {
    @State private var presentNextView = false
    @State private var nextView: ViewStack = .login
    @EnvironmentObject var loginVM: LoginViewModel
    
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                Spacer()
                Image("Sitting1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 370)
                    .padding(.top, 24)
                
                Spacer()
                
                Text("Motivation App")
                    .font(.system(size: 35, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("SystemBlueLight"))
                    .padding(.bottom, 8)
                
                
                Text("Every day is an opportunity for a fresh start.")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button {
                        nextView = .signup
                        presentNextView.toggle()
                    } label: {
                        Text("SIGNUP")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        
                    }
                    .frame(width: 160, height: 60)
                    .background(Color("SystemBlueLight"))
                    .cornerRadius(20)
                    
                    Button {
                        nextView = .login
                        presentNextView.toggle()
                    } label: {
                        Text("LOGIN")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                    }
                    .frame(width: 160, height: 60)
                    .background(Color("SystemBlueLight"))
                    .cornerRadius(20)
                    
                }
                .padding(.bottom, 20)
                
            }
            .padding()
            .navigationDestination(isPresented: $presentNextView) {
                switch nextView {
                case .login:
                    Login()
                case .signup:
                    Signup()
                }
            }
        }
    }
}

#Preview {
    Welcome()
        .environmentObject(LoginViewModel())
    
}

