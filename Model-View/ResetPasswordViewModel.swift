
import Foundation

class ResetPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var token: String = ""
    @Published var password: String = ""
    @Published var password_confirmation: String = ""
    @Published var message: String = ""
    @Published var isSuccess: Bool = false
    @Published var isLoading: Bool = false
    @Published var showResetPasswordView: Bool = false

    private let webservice = Webservice()

    var isValid: Bool {
        !password.isEmpty && password == password_confirmation && password.count >= 6
    }

    func resetPassword() {
        guard isValid else {
            message = "Passwords must match and be at least 6 characters"
            isSuccess = false
            return
        }

        isLoading = true
        message = ""

        webservice.resetPassword(email: email, token: token, password: password, password_confirmation: password_confirmation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let responseMessage):
                    self?.message = responseMessage
                    self?.isSuccess = true
                case .failure(let error):
                    self?.message = error.localizedDescription
                    self?.isSuccess = false
                }
            }
        }
    }
}

