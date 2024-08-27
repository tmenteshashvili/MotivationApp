
import SwiftUI

struct Main: View {
    @State var quotas = [Quote]()
    
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
            
            .task {
                do {
                    quotas = try await fetchQuotas()
                    print("Quotes fetched: \(quotas)")
                } catch {
                    print("Failed to fetch quotes: \(error)")
                }
            }
        }
        .padding()
    }
}


#Preview {
    Main()
}

