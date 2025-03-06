
import Foundation
import SwiftUI

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
}

extension UserDefaults {
    private static let key = "quoteHistory"

    func loadQuoteHistory() -> [SavedQuote] {
        guard let data = data(forKey: Self.key) else { return [] }
        return (try? JSONDecoder().decode([SavedQuote].self, from: data)) ?? []
    }

    func saveQuoteHistory(_ history: [SavedQuote]) {
        let data = try? JSONEncoder().encode(history)
        set(data, forKey: Self.key)
    }
}

func fetchQuotes() async throws -> [Quote] {
    let url = URL(string: "https://motivation.kakhoshvili.com/api/quotes")!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    do {
        let response = try JSONDecoder().decode(Quotes.self, from: data)
        
        var quoteHistory = UserDefaults.standard.loadQuoteHistory()
        
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        quoteHistory.removeAll { $0.fetchDate < oneMonthAgo }
        
        let seenQuoteIDs = Set(quoteHistory.map { $0.id })
        
        let availableQuotes = response.quotes.filter { !seenQuoteIDs.contains($0.id) }
        
        let finalQuotes = availableQuotes.isEmpty ? response.quotes : availableQuotes
        
        let newQuotesHistory = finalQuotes.map { SavedQuote(id: $0.id, fetchDate: Date()) }
        quoteHistory.append(contentsOf: newQuotesHistory)
        
        UserDefaults.standard.saveQuoteHistory(quoteHistory)
        
        return finalQuotes
        
    } catch {
        print("Decoding error: \(error)")
        throw error
    }
}
