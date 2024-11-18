
import Foundation
import SwiftUI


class RecoverPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var message: String = ""
    @Published var isLoading = false
    @Published var isSuccess = false

    
    private let webservice = Webservice()
    
    var isValidEmail: Bool {
         let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
         return emailPredicate.evaluate(with: email)
     }
     
    func resetPassword() {
        guard isValidEmail else {
                   message = "Please enter a valid email address"
            isSuccess = false
                   return
               }
               
               isLoading = true
               message = ""
        
        webservice.recoverPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let responseMessage):
                    self?.message = responseMessage
                    self?.isSuccess = true
                    self?.email = ""
                case .failure(let error):
                    self?.message = error.localizedDescription
                    self?.isSuccess = false
                }
            }
        }
    }
}
