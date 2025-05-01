
import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var savedQuotes: [String] = []
    
    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Favorite Quotes")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 20)
                }
                Spacer()
                
                if savedQuotes.isEmpty {
                    VStack {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Favorites are empty")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .offset(x:0, y: -300)
                } else {
                    List {
                        ForEach(savedQuotes, id: \.self) { quote in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(getQuoteAndAuthor(gottenQuote: quote).0)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                Text("\(getQuoteAndAuthor(gottenQuote: quote).1)")
                                    .font(.system(size: 12, weight: .light, design: .rounded))
                            }
                            .padding(.vertical, 10)
                        }
                        .onDelete(perform: removeRows)
                    }
                }
            }
        .onAppear {
            loadSavedQuotes()
        }
    }
    private func loadSavedQuotes() {
            savedQuotes = UserDefaults.standard.stringArray(forKey: "SavedQuotes") ?? []
        }
        
        private func getQuoteAndAuthor(gottenQuote: String) -> (String, String) {
            let components = gottenQuote.components(separatedBy: "—")
            if components.count >= 2 {
                return (components[0], components[1])
            }
            return (gottenQuote, "Unknown")
        }
        
        private func removeRows(at offsets: IndexSet) {
            savedQuotes.remove(atOffsets: offsets)
            UserDefaults.standard.set(savedQuotes, forKey: "SavedQuotes")
        }
    }


#Preview {
    FavoritesView()
}
