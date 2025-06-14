import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: QuoteService.Quote
}

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
                
                let currentPageInfo = getAppPageInfo()
                
                let shouldAdvancePage = shouldUpdatePage(lastUpdate: currentPageInfo.lastUpdateDate)
                
                let pageToFetch: Int
                if shouldAdvancePage {
                    pageToFetch = currentPageInfo.currentPage + 1
                    let newPageInfo = QuoteService.QuotePageInfo(
                        currentPage: pageToFetch,
                        lastUpdateDate: Date()
                    )
                    saveAppPageInfo(newPageInfo)
                } else {
                    pageToFetch = currentPageInfo.currentPage
                }
                
                let quotes = try await fetchQuotesFromAPI(page: pageToFetch)
                
                if !quotes.isEmpty {
                    let currentDate = Date()
                    var entries: [QuoteEntry] = []
                    
                    for hourOffset in stride(from: 0, to: 16, by: 4) {
                        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                        let quote = quotes[hourOffset / 4 % quotes.count]
                        let entry = QuoteEntry(date: entryDate, quote: quote)
                        entries.append(entry)
                    }
                    
                    cacheQuotes(quotes, forPage: pageToFetch)
                    
                    let nextRefresh = Calendar.current.date(byAdding: .hour, value: 4, to: currentDate) ?? currentDate
                    let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
                    completion(timeline)
                    
                   
                } else {
                    handleNoQuotes(completion: completion)
                }
                
            } catch {
                handleNoQuotes(completion: completion)
            }
        }
    }
    
    private func shouldUpdatePage(lastUpdate: Date) -> Bool {
        let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)
        let threshold: TimeInterval = 4 * 60 * 60 // 4 hours - EXACT same as app
        let shouldUpdate = timeSinceUpdate >= threshold
     
        return shouldUpdate
    }
    
    private func getAppPageInfo() -> QuoteService.QuotePageInfo {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        
        if let data = defaults?.data(forKey: "pageInfo"),
           let pageInfo = try? JSONDecoder().decode(QuoteService.QuotePageInfo.self, from: data) {
            return pageInfo
        }
        
        let newPageInfo = QuoteService.QuotePageInfo(currentPage: 1, lastUpdateDate: Date())
        saveAppPageInfo(newPageInfo)
        return newPageInfo
    }
    
    private func saveAppPageInfo(_ pageInfo: QuoteService.QuotePageInfo) {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        
        if let encoded = try? JSONEncoder().encode(pageInfo) {
            defaults?.set(encoded, forKey: "pageInfo") // SAME key as app
        }
    }
    
    private func fetchQuotesFromAPI(page: Int) async throws -> [QuoteService.Quote] {
        let baseURL = "https://motivation.kakhoshvili.com/api"
        let url = URL(string: "\(baseURL)/quotes?page=\(page)")!
        
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "WidgetError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch quotes"])
        }
        
        let quotesResponse = try JSONDecoder().decode(QuoteService.Quotes.self, from: data)
        return quotesResponse.quotes
    }
    
    private func cacheQuotes(_ quotes: [QuoteService.Quote], forPage page: Int) {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        if let encoded = try? JSONEncoder().encode(quotes) {
            defaults?.set(encoded, forKey: "cachedWidgetQuotes")
            defaults?.set(Date(), forKey: "quotesLastCached")
            defaults?.set(page, forKey: "cachedQuotesPage")
        }
    }
    
    private func getCachedQuotes() -> [QuoteService.Quote]? {
        let defaults = UserDefaults(suiteName: "group.com.takomenteshashvili.MotivationApp")
        
        if let lastCached = defaults?.object(forKey: "quotesLastCached") as? Date,
           Date().timeIntervalSince(lastCached) < 8 * 60 * 60,
           let data = defaults?.data(forKey: "cachedWidgetQuotes"),
           let quotes = try? JSONDecoder().decode([QuoteService.Quote].self, from: data) {
            
            let cachedPage = defaults?.integer(forKey: "cachedQuotesPage") ?? 1
            return quotes
        }
        
        return nil
    }
    
    private func handleNoQuotes(completion: @escaping (Timeline<QuoteEntry>) -> ()) {
        if let cachedQuotes = getCachedQuotes(), !cachedQuotes.isEmpty {
            let entry = QuoteEntry(date: Date(), quote: cachedQuotes.randomElement()!)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        } else {
            let fallbackQuotes = getFallbackQuotes()
            let entry = QuoteEntry(date: Date(), quote: fallbackQuotes.randomElement()!)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(7200)))
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
