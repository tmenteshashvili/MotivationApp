import SwiftUI

struct RecoverPasswordView: View {
    @StateObject private var viewModel = RecoverPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 20) {
        
                Image("girl1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                
                Text("Don’t worry! It happens. Please enter the email associated with your account.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color("SystemBackgroundLightSecondary"))
                    .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("SystemBlueLight"), lineWidth: 3)
                    )
                
            }
            .padding(.horizontal)
            .padding(.top, 80)
            
//            Spacer()
            
//            if viewModel.isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//            }
//            
//            if !viewModel.message.isEmpty {
//                Text(viewModel.message)
//                    .foregroundColor(viewModel.isSuccess ? .green : .red)
//                    .font(.system(size: 14))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//
            Spacer()
                Button {
                    viewModel.resetPassword()
                } label: {
                    Text("Submit")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    
                }
                .disabled(viewModel.isLoading || !viewModel.isValidEmail)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("SystemBlueLight"))
                .cornerRadius(20)
                .padding(.horizontal)
       
            
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .foregroundStyle(.red)
                    .padding(.top)
            }
            
        }
    }
    
}



#Preview {
    RecoverPasswordView()
}
