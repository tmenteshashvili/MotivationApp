import SwiftUI

struct RecoverPassword: View {
    
    @AppStorage("isDarkMode") private var isDark = false
    @StateObject private var viewModel = RecoverPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image("girl1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Text("Don’t worry! It happens. Please enter the email associated with your account.")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color("Logbuttonlight"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("borderLine"), lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .foregroundColor(viewModel.isSuccess ? .green : .red)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            
            Button {
                viewModel.resetPassword()
            } label: {
                Text("Submit")
                    .font(.system(size: 20, weight: .semibold))
                   
                
            }
            .disabled(viewModel.isLoading || !viewModel.isValidEmail)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(Color("txt"))
            .cornerRadius(20)
            .padding(.horizontal)
            
            
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .foregroundStyle(.red)
                    .padding(.top)
            }
            
        }.navigationTitle("forgot password")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
}



#Preview {
    RecoverPassword()
}
