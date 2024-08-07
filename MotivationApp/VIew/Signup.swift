
import SwiftUI

struct Signup: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userName = ""
    @State private var confirmPassword = ""
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isValidConfirmPassword = true
    @State private var isValidUserName = true


    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                Image("Standing1")
                
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isValidEmail ? .red : focusedField == .email ? Color("borderLine") : .white, lineWidth: 3)
                    )
                    .padding(.horizontal)
                    .onChange(of: email) {
                        isValidEmail = Validator.validateEmail(email)
                    }
                if !isValidEmail {
                    HStack {
                        Text("Your email is not valid!")
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Spacer()
                    }
                }
                
                TextField("Username", text: $userName)
                    .focused($focusedField, equals: .username)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isValidUserName ? .red : focusedField == .username ? Color("borderLine") : .white, lineWidth: 3)
                    )
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .focused($focusedField, equals: .password)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isValidPassword ? .red : focusedField == .password ? Color("borderLine") : .white, lineWidth: 3)
                            
                    )
                    .padding(.horizontal)
                SecureField("Confirm password", text: $confirmPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isValidConfirmPassword ? .red : focusedField == .confirmPassword ? Color("borderLine") : .white, lineWidth: 3)
                            
                    )
                    .padding(.horizontal)
              
                Spacer()
                Spacer()
                
                Button {
                    
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
            
           
        }
        .navigationTitle("signup")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Signup()
}
