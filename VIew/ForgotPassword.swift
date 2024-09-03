import SwiftUI

struct ForgotPassword: View {
    

    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                Image("girl1")
                
                Text("Don’t worry! It happens. Please enter the email associated with your account.")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                           RoundedRectangle(cornerRadius: 20)
                               .stroke(Color("borderLine"), lineWidth: 2)
                       )
                    .padding(.horizontal)
                  
                Spacer()
               
                Button {
                    viewModel.resetPassword()
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
                
                
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundStyle(.red)
                        .padding(.top)
                }
                
            }           
        }
        .navigationTitle("forgot password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ForgotPassword()
}
