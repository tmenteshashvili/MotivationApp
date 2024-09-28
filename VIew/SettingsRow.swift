

import SwiftUI

struct SettingsRow: View {
    
    var imageName: String
    var title: String
    var action: (()->()) = {}

    var body: some View {
        Button(action: {
          
        }) {
            HStack(spacing: 8) {
                Image(systemName: imageName)
                    .frame(minWidth: 25, alignment: .leading)
                    .accessibility(hidden: true)
                Text(title)
                    .kerning(1)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .padding(.vertical, 10)
            .foregroundColor(.primary)
        }
    }
}
