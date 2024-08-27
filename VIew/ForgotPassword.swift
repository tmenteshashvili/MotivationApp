import SwiftUI

struct ForgotPassword: View {
    
    @State private var email = ""
    @State private var isValidEmail = true

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                Image("girl1")
                
                Text("Don’t worry! It happens. Please enter the email associated with your account.")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .padding()
                
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
                Spacer()
               
                Button {
                    
                } label: {
                    Text("Submit")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color("Txtebackground"))
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("Logbuttondurk"))
                .cornerRadius(20)
                .padding(.horizontal)
                
            }
            
           
        }
        .navigationTitle("forgot password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ForgotPassword()
}
