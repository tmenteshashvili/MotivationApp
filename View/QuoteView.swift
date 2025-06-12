
import SwiftUI
import UserNotifications

struct QuoteView: View {
    @StateObject private var viewModel = QuoteViewModel()
    @State private var navigateToReminder = false
    @State private var showingSettingsSheet = false
    @State private var isSharePresented = false
    @State private var showingFavoritesView = false
    @AppStorage("firstLaunch") private var isFirstLaunch = true
    

    var body: some View {
        ZStack {
            Image("Hands")
                .offset(y: 210)
            GeometryReader { proxy in
                TabView {
                    ForEach(viewModel.quotes) { quote in
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
            .navigationDestination(isPresented: $showingFavoritesView) {
                FavoritesView()
            }
            .task {
                do {
                    if isFirstLaunch {
                        
                        viewModel.loadQuotes()
                        isFirstLaunch = false
                    } else {
                        
                        viewModel.loadQuotes()
                    }
                } catch {
                    print("Failed to fetch quotes: \(error)")
                }
            }
            .sheet(isPresented: $showingFavoritesView) {
                FavoritesView()
            }
        }
    }
}

#Preview {
    QuoteView()
}

