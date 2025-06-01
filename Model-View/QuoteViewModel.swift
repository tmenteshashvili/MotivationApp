import Foundation

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quotes: [QuoteService.Quote] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let quoteService = QuoteService()
    
    func loadQuotes() {
        Task { @MainActor in
            do {
                isLoading = true
                error = nil
                quotes = try await quoteService.fetchQuotes()
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidCredentials:
                self.error = "Authentication failed"
            case .serverError(let message):
                self.error = "Server error: \(message)"
            case .decodingError(let message):
                self.error = "Data error: \(message)"
            case .custom(let message):
                self.error = message
            }
        } else {
            self.error = "An unexpected error occurred"
        }
    }
}
