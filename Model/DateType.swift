
import Foundation
import SwiftUI


class QuoteService: ObservableObject {
    @Published var quotes: [Quote] = []
    private let baseURL = "https://motivation.kakhoshvili.com/api"
    private let defaults = UserDefaults.standard
    
    struct Quotes: Codable {
        var quotes: [Quote]
    }
    
    struct Quote: Identifiable, Codable {
        var id: Int
        var category: String
        var type: String
        var author: String
        var content: String
        var url: String?
    }
    
    struct SavedQuote: Codable {
        let id: Int
        let fetchDate: Date
        let pageNumber: Int
    }
    
    struct QuotePageInfo: Codable{
        var currentPage: Int
        var lastUpdateDate: Date
        static let defaultPageChangeInterval: TimeInterval = 2 * 24 * 60 * 60
    }
    
    private enum UserDefaultsKeys {
        static let quoteHistory = "qouteHistory"
        static let pageInfo = "qoutepageInfo"
    }
    
    
    func fetchQuotes() async throws -> [Quote] {
        let pageInfo = getCurrentPageInfo()
        
        if shouldUpdatePage(lastUpdate: pageInfo.lastUpdateDate) {
            let nextPage = pageInfo.currentPage + 1
            let newPageInfo = QuotePageInfo(currentPage: nextPage,
                                            lastUpdateDate: Date())
            savePageInfo(newPageInfo)
        }
        
        let url = URL(string: "\(baseURL)/quotes?page=\(pageInfo.currentPage)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(message: "Failed to fetch quotes")
        }
        
        do {
            let response = try JSONDecoder().decode(Quotes.self, from: data)
            let filteredQuotes = filterNewQuotes(response.quotes)
            
            await MainActor.run {
                self.quotes = filteredQuotes
            }
            
            saveToQuoteHistory(filteredQuotes, pageNumber: pageInfo.currentPage)
            
            return filteredQuotes
        } catch {
            throw NetworkError.decodingError(message: "Failed to decode quotes: \(error.localizedDescription)")
        }
    }
    
    private func getCurrentPageInfo() -> QuotePageInfo {
        if let data = defaults.data(forKey: UserDefaultsKeys.pageInfo),
           let pageInfo = try? JSONDecoder().decode(QuotePageInfo.self, from: data) {
            return pageInfo
        }
        return QuotePageInfo(currentPage: 1, lastUpdateDate: Date())
    }
    
    private func savePageInfo(_ pageInfo: QuotePageInfo) {
        if let encoded = try? JSONEncoder().encode(pageInfo) {
            defaults.set(encoded, forKey: UserDefaultsKeys.pageInfo)
        }
    }
    
    private func shouldUpdatePage(lastUpdate: Date) -> Bool {
        return Date().timeIntervalSince(lastUpdate) >= QuotePageInfo.defaultPageChangeInterval
    }
    
    private func loadQuoteHistory() -> [SavedQuote] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.quoteHistory) else {
            return []
        }
        return (try? JSONDecoder().decode([SavedQuote].self, from: data)) ?? []
    }
    
    private func saveQuoteHistory(_ history: [SavedQuote]) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: UserDefaultsKeys.quoteHistory)
        }
    }
    
    private func filterNewQuotes(_ quotes: [Quote]) -> [Quote] {
        var quoteHistory = loadQuoteHistory()
        
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        quoteHistory.removeAll { $0.fetchDate < oneMonthAgo }
        
        let seenQuoteIDs = Set(quoteHistory.map { $0.id })
        
        let availableQuotes = quotes.filter { !seenQuoteIDs.contains($0.id) }
        
        return availableQuotes.isEmpty ? quotes : availableQuotes
    }
    
    private func saveToQuoteHistory(_ quotes: [Quote], pageNumber: Int) {
        var history = loadQuoteHistory()
        let newQuotesHistory = quotes.map {
            SavedQuote(id: $0.id,
                       fetchDate: Date(),
                       pageNumber: pageNumber)
        }
        history.append(contentsOf: newQuotesHistory)
        saveQuoteHistory(history)
    }
}
