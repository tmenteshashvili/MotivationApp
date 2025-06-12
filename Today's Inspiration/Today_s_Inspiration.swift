import WidgetKit
import SwiftUI

// MARK: - Widget Provider
struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quote: QuoteService.Quote(
                id: 1,
                category: "Motivational",
                type: "text",
                author: "Steve Jobs",
                content: "The only way to do great work is to love what you do."
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let entry = QuoteEntry(
            date: Date(),
            quote: QuoteService.Quote(
                id: 1,
                category: "Motivational",
                type: "text",
                author: "Maya Angelou",
                content: "Try to be a rainbow in someone's cloud."
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> ()) {
        Task {
            do {
                // Try to fetch quotes from your API
                let quotes = try await fetchQuotesFromAPI()
                let currentDate = Date()
                
                // If we got quotes, create timeline entries
                if !quotes.isEmpty {
                    var entries: [QuoteEntry] = []
                    
                    // Update every 4 hours with different quotes
                    for hourOffset in stride(from: 0, to: 24, by: 4) {
                        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                        let quote = quotes[hourOffset / 4 % quotes.count]
                        let entry = QuoteEntry(date: entryDate, quote: quote)
                        entries.append(entry)
                    }
                    
                    // Cache quotes locally for offline use
                    cacheQuotes(quotes)
                    
                    // Refresh timeline at the end of the day
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                    let timeline = Timeline(entries: entries, policy: .after(tomorrow))
                    completion(timeline)
                } else {
                    // No quotes received, use cached or fallback
                    handleNoQuotes(completion: completion)
                }
                
            } catch {
                print("Widget: Error fetching quotes: \(error)")
                // Try to use cached quotes first, then fallback
                handleNoQuotes(completion: completion)
            }
        }
    }
    
    private func fetchQuotesFromAPI() async throws -> [QuoteService.Quote] {
        let baseURL = "https://motivation.kakhoshvili.com/api"
        
        // Get current page info (similar to your QuoteService)
        let pageInfo = getCurrentPageInfo()
        let url = URL(string: "\(baseURL)/quotes?page=\(pageInfo.currentPage)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(message: "Failed to fetch quotes")
        }
        
        let quotesResponse = try JSONDecoder().decode(QuoteService.Quotes.self, from: data)
        return quotesResponse.quotes
    }
    
    private func getCurrentPageInfo() -> QuoteService.QuotePageInfo {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        
        if let data = defaults?.data(forKey: "widgetPageInfo"),
           let pageInfo = try? JSONDecoder().decode(QuoteService.QuotePageInfo.self, from: data) {
            return pageInfo
        }
        
        // Default to page 1 if no info available
        return QuoteService.QuotePageInfo(currentPage: 1, lastUpdateDate: Date())
    }
    
    private func cacheQuotes(_ quotes: [QuoteService.Quote]) {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        if let encoded = try? JSONEncoder().encode(quotes) {
            defaults?.set(encoded, forKey: "cachedWidgetQuotes")
            defaults?.set(Date(), forKey: "quotesLastCached")
        }
    }
    
    private func getCachedQuotes() -> [QuoteService.Quote]? {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        
        // Check if cached quotes are recent (less than 24 hours old)
        if let lastCached = defaults?.object(forKey: "quotesLastCached") as? Date,
           Date().timeIntervalSince(lastCached) < 24 * 60 * 60,
           let data = defaults?.data(forKey: "cachedWidgetQuotes"),
           let quotes = try? JSONDecoder().decode([QuoteService.Quote].self, from: data) {
            return quotes
        }
        
        return nil
    }
    
    private func handleNoQuotes(completion: @escaping (Timeline<QuoteEntry>) -> ()) {
        // Try cached quotes first
        if let cachedQuotes = getCachedQuotes(), !cachedQuotes.isEmpty {
            let entry = QuoteEntry(date: Date(), quote: cachedQuotes.randomElement()!)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1800))) // Retry in 30 minutes
            completion(timeline)
        } else {
            // Use fallback quotes as last resort
            let fallbackQuotes = getFallbackQuotes()
            let entry = QuoteEntry(date: Date(), quote: fallbackQuotes.randomElement()!)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))) // Retry in 1 hour
            completion(timeline)
        }
    }
    
    private func getFallbackQuotes() -> [QuoteService.Quote] {
        return [
            QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Nelson Mandela", content: "It always seems impossible until it's done."),
            QuoteService.Quote(id: 2, category: "Motivational", type: "text", author: "Walt Disney", content: "The way to get started is to quit talking and begin doing."),
            QuoteService.Quote(id: 3, category: "Motivational", type: "text", author: "Eleanor Roosevelt", content: "The future belongs to those who believe in the beauty of their dreams."),
            QuoteService.Quote(id: 4, category: "Motivational", type: "text", author: "Oprah Winfrey", content: "The greatest discovery of all time is that a person can change his future by merely changing his attitude."),
            QuoteService.Quote(id: 5, category: "Motivational", type: "text", author: "Steve Jobs", content: "Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work.")
        ]
    }
}

// MARK: - Timeline Entry
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: QuoteService.Quote
}

// MARK: - Widget Views
struct QuoteWidgetSmallView: View {
    let entry: QuoteEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Text(entry.quote.content)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Text("— \(entry.quote.author)")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QuoteWidgetMediumView: View {
    let entry: QuoteEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Quote")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(entry.quote.content)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                
                Spacer()
                
                Text("— \(entry.quote.author)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quote icon or decorative element
            Image(systemName: "quote.closing")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.blue.opacity(0.3))
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QuoteWidgetLargeView: View {
    let entry: QuoteEntry
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Inspiration")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.blue.opacity(0.5))
                
                Text(entry.quote.content)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .minimumScaleFactor(0.8)
                
                Text("— \(entry.quote.author)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Text("Category: \(entry.quote.category)")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDate(entry.date))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Main Widget Entry View
struct QuoteWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: QuoteEntry

    var body: some View {
        switch family {
        case .systemSmall:
            QuoteWidgetSmallView(entry: entry)
        case .systemMedium:
            QuoteWidgetMediumView(entry: entry)
        case .systemLarge:
            QuoteWidgetLargeView(entry: entry)
        default:
            QuoteWidgetMediumView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration
struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetEntryView(entry: entry)
                .containerBackground(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    for: .widget
                )
                .widgetURL(URL(string: "motivationapp://open"))
        }
        .configurationDisplayName("Daily Quote")
        .description("Get inspired with daily motivational quotes")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
