
import SwiftUI

struct PasswordTextField: View {
    @State private var isValidPassword = true
    let errorText: String
    
    @FocusState private var focusedField: FocusedField?
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some View {
        
        VStack {
            SecureField("Password", text: $loginVM.password)
                .focused($focusedField, equals: .password)
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
                    Text(errorText)
                        .foregroundStyle(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    PasswordTextField(errorText: "Your password in not valid")
}
