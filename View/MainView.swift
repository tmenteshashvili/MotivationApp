
import SwiftUI
import UserNotifications

struct MainView: View {
    @State var quotas = [Quote]()
    @State private var navigateToReminder = false
    @State private var showingSettingsSheet = false

    
    var body: some View {
        
        ZStack {
            Image("Hands")
                .offset(y: 190)
            GeometryReader { proxy in
                TabView {
                    ForEach(quotas) { quote in
                        QuoteView(quote: quote)
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
            VStack {
                Button(action: {
                    
                    self.showingSettingsSheet.toggle()
                    
                    
                }) {
                    Image(systemName: "gearshape")
                        .renderingMode(.original)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                        .padding()
                }.sheet(isPresented: $showingSettingsSheet) {
                    SettingView()
                        .edgesIgnoringSafeArea(.bottom)
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(14)
                .buttonStyle(PlainButtonStyle())
            }
            .offset(x: 150, y: -370)

            .task {
                do {
                    quotas = try await fetchQuotas()
                    print("Quotes fetched: \(quotas)")
                    navigateToReminder = true
                } catch {
                    print("Failed to fetch quotes: \(error)")
                }
            }
        }
        .padding()
    }
}


#Preview {
    MainView()
}

