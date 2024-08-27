//
//  QuoteView.swift
//  MotivationApp
//
//  Created by Tako Menteshashvili on 15.08.24.
//

import SwiftUI

struct QuoteView: View {
    public var quote: Quote
    
    public init(quote: Quote) {
        self.quote = quote
    }
    
    var body: some View {
        
        VStack {
            Text(quote.content)
                .font(.custom("AveriaSerifLibre-Bold", size: 25))
                .multilineTextAlignment(.center)
            Text(quote.author)
                .font(.system(size: 18, weight: .bold))
        }
        .fixedSize(horizontal: false, vertical: true)
        
    }
}



#Preview {
    QuoteView(quote: Quote(id: 11, category: "Motivational", type: "text", author: "Theodore Roosevelt", content: "Do what you can, with what you have, where you are."))
}
