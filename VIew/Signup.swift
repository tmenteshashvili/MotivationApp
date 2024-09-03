
import SwiftUI

struct Signup: View {
    
    @State private var message: String = ""
    @StateObject private var SignupVM = SignupViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
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
                        .foregroundStyle(Color("Txtebackground"))
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("Logbuttondurk"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Text(SignupVM.message)
                    .foregroundColor(.red)
                    .padding()
                
            }
            
            HStack(spacing: 15) {
                Rectangle()
                    .fill(Color("Txtebackground"))
                    .frame(height: 1)
                Text("OR")
                Rectangle()
                    .fill(Color("Txtebackground"))
                    .frame(height: 1)
            }
            .padding(.horizontal,20)
            .padding(.top,30)
            
            
            HStack(spacing: 70) {
                Button {
                    
                } label: {
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                }
                Button {
                    
                } label: {
                    Image("fb")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                }
                Button {
                    
                } label: {
                    Image("apple")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
            }
            .padding(.bottom,5)
            .navigationTitle("signup")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(.white)
        
    }
    
}

#Preview {
    Signup()
}
