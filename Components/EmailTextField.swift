
import SwiftUI

struct EmailTextField: View {
    @State private var isValidEmail = true
    @StateObject private var loginVM = LoginViewModel()
    @FocusState private var focusedField: FocusedField?

    let title: String
    let errorText: String
    
    var body: some View {
        
        VStack {
            
            TextField(title, text: $loginVM.email)
                .focused($focusedField, equals: .email)
                .padding()
                .background(Color("SystemBackgroundLightSecondary"))
                .cornerRadius(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("SystemBlueLight"), lineWidth: 3)
                )
                .padding(.horizontal)
                .onChange(of: loginVM.email) { oldValue, newValue in
                    isValidEmail = Validator.validateEmail(newValue)
                }
            if !isValidEmail {
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
    EmailTextField(title: "Email", errorText: "Your email in not valid")
}
