
import SwiftUI

struct MainView: View {
    @State private var selectedTab = UserDefaults.standard.integer(forKey: "selectedTab")
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                QuoteView()
                    .tabItem {
                        Label("Quote", systemImage: "quote.closing")
                        
                    }
                    .tag(0)
                
                FavoritesView()
                    .tabItem {
                        Label("Favorite", systemImage: "heart.fill")
                    }
                    .tag(1)
                
                SettingView()
                    .tabItem {
                        Label("Settings", systemImage: "person.fill")
                    }
                    .tag(2)
            }
            .onAppear {
                if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                    selectedTab = 0
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                }
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                UserDefaults.standard.set(newValue, forKey: "selectedTab")
                
            }
        }
    }
}



#Preview {
    MainView()
}

