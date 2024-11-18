
import SwiftUI

struct Signup: View {
    @AppStorage("isDarkMode") private var isDark = false
    @StateObject private var SignupVM = SignupViewModel()
    
    var body: some View {
        NavigationStack {
            LazyVStack {
                Spacer()
                
                Image("Standing1")
                    .resizable()
                    .scaledToFit()
                
                
                TextField("Email", text: $SignupVM.email)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                
                TextField("Fullname", text: $SignupVM.full_name)
                    .padding()
                
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                SecureField("Password", text: $SignupVM.password)
                    .padding()
                    .background(Color("Logbuttonlight"))
                
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                SecureField("Confirm password", text: $SignupVM.password_confirmation)
                    .padding()
                    .background(Color("Logbuttonlight"))
                
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                
                Button {
                    SignupVM.signup()
                } label: {
                    Text("Sign up")
                        .font(.system(size: 20, weight: .semibold))
                        
                    
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("txt"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Text(SignupVM.message)
                    .foregroundColor(.red)
                    .padding()
            }
            .navigationDestination(isPresented: $SignupVM.isAuthenticated) {
                           Remainder(howMany: 3, startTime: Date(), endTime: Date().addingTimeInterval(3600), quotes: [
                               Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                           ])
                       }
            
            .padding(.bottom,5)
            .navigationTitle("signup")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
}

#Preview {
    Signup()
}





