
import SwiftUI
import UserNotifications

struct QuoteView: View {
    @State var quotas = [Quote]()
    @State private var navigateToReminder = false
    @State private var showingSettingsSheet = false
    @State private var selectedQuote: Quote?
    @State private var isSharePresented = false
    @State private var showingFavoritesView = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("Hands")
                    .offset(y: 210)
                GeometryReader { proxy in
                    TabView {
                        ForEach(quotas) { quote in
                            EachQuote(quote: quote)
                        }
                        .rotationEffect(.degrees(-90))
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                    }
                    .frame(
                        width: proxy.size.height,
                        height: proxy.size.width
                    )
                    .rotationEffect(.degrees(90), anchor: .topLeading)
                    .offset(x: proxy.size.width)
                    .tabViewStyle(
                        PageTabViewStyle(indexDisplayMode: .never)
                    )
                }
                
                Button(action: {
                    showingFavoritesView = true
                }) {
                    EmptyView()
                }
            }
            .navigationDestination(isPresented: $showingFavoritesView) {
                FavoritesView()
            }
        }
        .task {
            do {
                quotas = try await fetchQuotes()
                print("Quotes fetched: \(quotas)")
                navigateToReminder = true
            } catch {
                print("Failed to fetch quotes: \(error)")
            }
        }
    }
}


#Preview {
    QuoteView()
}

