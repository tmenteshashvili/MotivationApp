import SwiftUI

enum ViewStack {
    case login
    case signup
}

struct Welcome: View {
    @State private var presentNextView = false
    @State private var nextView: ViewStack = .login
    
    var body: some View {
    
        NavigationStack {
            ZStack {
                Image("Ellipse1")
                    .offset(x: 120, y: -340)
                
                Image("Ellipse2.1")
                    .resizable()
                    .scaledToFill()
                    .offset(y: 280)
                
                VStack {
                    Spacer()
                    Text("Motivation App")
                        .font(.system(size: 35, weight: .heavy))
                        .offset(x: -25, y: -100)
                Spacer()
                    Image("Sitting1")
                        .frame(width: 370)
                        .padding(.top, 24)
                        .offset(y: -120)
                    
                    Spacer()
                    HStack(spacing: 10) {
                        Button {
                            nextView = .signup
                            presentNextView.toggle()
                        } label: {
                            Text("SIGNUP")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("Txtebackground"))
                        }
                        .frame(width: 160, height: 60)
                        .background(Color("Buttonbackground"))
                        .cornerRadius(20)
                        
                        Button {
                            nextView = .login
                            presentNextView.toggle()
                        } label: {
                            Text("LOGIN")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("Txtebackground"))
                        }
                        .frame(width: 160, height: 60)
                        .background(Color("Buttonbackground"))
                        .cornerRadius(20)
                        
                    }
                    .padding(.bottom)
                    
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
}

#Preview {
    Welcome()
}
