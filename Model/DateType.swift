
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

func fetchQuotas() async throws -> [Quote] {
    let url = URL(string: "https://motivation.kakhoshvili.com/api/quotes")!
    let (data, _) = try await URLSession.shared.data(from: url)
    do {
        let response = try JSONDecoder().decode(Quotes.self, from: data)
        return response.quotes
    } catch {
        print("Decoding error: \(error)")
        throw error
    }
}

