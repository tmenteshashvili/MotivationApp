
import SwiftUI
enum FocusedField {
    case email
    case password
    case username
}

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isValidEmail = true
    @State private var isValidPassword = true

    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()
                Image("OnFloor1")
                
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
                    .onChange(of: password) {
                        isValidPassword = Validator.validatePassword(password)
                    }
                if !isValidPassword {
                    HStack {
                        Text("Your password is not valid!")
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Spacer()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        
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
        }
        .navigationTitle("login")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Login()
}
