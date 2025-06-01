
import SwiftUI

struct EachQuote: View {
    public var quote: QuoteService.Quote
    @State private var isLiked = false
    
    public init(quote: QuoteService.Quote) {
        self.quote = quote
        
        
        _isLiked = State(initialValue: UserDefaults.standard.loadLikedQuotes().contains(quote.id))
        
    }
    
    var body: some View {
        VStack(spacing: 20){
            VStack(spacing: 10) {
                Text(quote.content)
                    .font(.custom("AveriaSerifLibre-Bold", size: 25))
                    .multilineTextAlignment(.center)
                Text(quote.author)
                    .font(.system(size: 18, weight: .bold))
            }
            .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 20) {
                Button(action: handleLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .renderingMode(.original)
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(14)
                .buttonStyle(PlainButtonStyle())
                
                Button(action: handleShare) {
                    Image(systemName: "square.and.arrow.up")
                        .renderingMode(.original)
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.gray.opacity(0.3))
                .cornerRadius(14)
                .buttonStyle(PlainButtonStyle())
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
        }
    }
    private func handleLike() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            isLiked.toggle()
            
            let quoteString = "\(quote.content)—\(quote.author)"
            var savedQuotes = UserDefaults.standard.stringArray(forKey: "SavedQuotes") ?? []
            
            if isLiked {
                if !savedQuotes.contains(quoteString) {
                    savedQuotes.append(quoteString)
                }
            } else {
                savedQuotes.removeAll { $0 == quoteString }
            }
            UserDefaults.standard.set(savedQuotes, forKey: "SavedQuotes")
            
            var likedQuotes = UserDefaults.standard.loadLikedQuotes()
            if isLiked {
                likedQuotes.insert(quote.id)
            } else {
                likedQuotes.remove(quote.id)
            }
            UserDefaults.standard.saveLikedQuotes(likedQuotes)
    }
    
    private func handleShare() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let shareText = "\"\(quote.content)\" — \(quote.author)"
        
        let av = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let controller = window.rootViewController {
            controller.present(av, animated: true)
        }
    }
}

extension UserDefaults {
    func loadLikedQuotes() -> Set<Int> {
        let array = self.array(forKey: "LikedQuotes") as? [Int] ?? []
        return Set(array)
    }
    
    func saveLikedQuotes(_ quoteIds: Set<Int>) {
        self.set(Array(quoteIds), forKey: "LikedQuotes")
    }
}



#Preview {
    EachQuote(quote: QuoteService.Quote(id: 11, category: "Motivational", type: "text", author: "Theodore Roosevelt", content: "Do what you can, with what you have, where you are."))
}
