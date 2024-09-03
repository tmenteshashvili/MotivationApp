

import Foundation


class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var message: String = ""
    
    func resetPassword() {
        
        Webservice().resetPassword(email: email) { result in
            switch result {
            case .success(let responseMessage):
                DispatchQueue.main.async {
                    self.message = responseMessage
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.message = error.localizedDescription
                }
            }
        }
    }
}
