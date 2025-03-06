
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            
            QuoteView()
                .tabItem {
                    Label("Quote", systemImage: "quote.closing")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorite", systemImage: "heart.fill")
                }
            SettingView()
                .tabItem {
                    Label("Settings", systemImage: "person.fill")
                }
        }
    }
    
}



#Preview {
    MainView()
}

