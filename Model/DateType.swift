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
        static let defaultPageChangeInterval: TimeInterval = 4 * 60 * 60
    }
    
    enum UserDefaultsKeys {
        static let quoteHistory = "quoteHistory"
        static let pageInfo = "pageInfo"
        static let likedQuotes = "LikedQuotes"
        static let savedQuotes = "SavedQuotes"
        static let jwt = "JWT"
        static let userEmail = "user_email"
        static let userFullName = "user_fullname"
    }

    func fetchQuotes(forceNewPage: Bool = false) async throws -> [Quote] {
        var pageInfo = getCurrentPageInfo()
    
        
        let shouldAdvance = forceNewPage || shouldUpdatePage(lastUpdate: pageInfo.lastUpdateDate)
   
        
        if shouldAdvance {
            let nextPage = pageInfo.currentPage + 1
            pageInfo = QuotePageInfo(currentPage: nextPage, lastUpdateDate: Date())
            savePageInfo(pageInfo)
          
            let verifyPageInfo = getCurrentPageInfo()
            print("Verified: Page saved as \(verifyPageInfo.currentPage)")
        } else {
            print("Staying on page \(pageInfo.currentPage)")
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
            
            if filteredQuotes.count > 0 {
                let sampleIds = filteredQuotes.prefix(3).map { $0.id }
                print("📋 Sample IDs: \(sampleIds)")
            }
            
            return filteredQuotes
        } catch {
            throw NetworkError.decodingError(message: "Failed to decode quotes: \(error.localizedDescription)")
        }
    }
    
    func fetchQuotesForNotifications() async throws -> [Quote] {
        return try await fetchQuotes(forceNewPage: true)
    }
    
    private func shouldUpdatePage(lastUpdate: Date) -> Bool {
        let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)
        let threshold: TimeInterval =  4 * 60 * 60
          let shouldUpdate = timeSinceUpdate >= threshold
          return shouldUpdate
    }
    
    private func getCurrentPageInfo() -> QuotePageInfo {
        if let data = defaults.data(forKey: UserDefaultsKeys.pageInfo),
           let pageInfo = try? JSONDecoder().decode(QuotePageInfo.self, from: data) {
            return pageInfo
        }
        let firstTimeDate = Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date()
        let newPageInfo = QuotePageInfo(currentPage: 1, lastUpdateDate: firstTimeDate)
           savePageInfo(newPageInfo)
           return newPageInfo
        
        
    }
    
    private func savePageInfo(_ pageInfo: QuotePageInfo) {
        if let encoded = try? JSONEncoder().encode(pageInfo) {
            defaults.set(encoded, forKey: UserDefaultsKeys.pageInfo)
        }
    }
    
    private func filterNewQuotes(_ quotes: [Quote]) -> [Quote] {
        
        var quoteHistory = loadQuoteHistory()
        
        let halfMonthAgo = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
        quoteHistory.removeAll { $0.fetchDate < halfMonthAgo }
        
        let seenQuoteIDs = Set(quoteHistory.map { $0.id})
        let availableQuotes = quotes.filter { !seenQuoteIDs.contains($0.id)}
        
        return availableQuotes.isEmpty ? quotes : availableQuotes
    }
    
    private func loadQuoteHistory() -> [SavedQuote] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.quoteHistory) else {
            return []
        }
        return (try? JSONDecoder().decode([SavedQuote].self, from: data)) ?? []
    }
    
    private func saveToQuoteHistory(_ quotes: [Quote], pageNumber: Int) {
       var history = loadQuoteHistory()
        let newQuotesHistory = quotes.map {
            SavedQuote(id: $0.id, fetchDate: Date(), pageNumber: pageNumber)
        }
        history.append(contentsOf: newQuotesHistory)
        
        if let encoded =  try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: UserDefaultsKeys.quoteHistory)
        }
    }
}
