
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Welcome()
            }
        }
        
        .onOpenURL(perform: handleIncomingURL)
        
    }
    
}


private func handleIncomingURL(_ url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("Invalid URL")
        return
    }
    
    guard let action = components.host, action == "recover" else {
        print("Unknown URL, we can't handle this one!")
        return
    }
    
    //        guard let email = components.queryItems?.first(where: { $0.name == "email" })?.value else {
    //            return
    //        }
    //
    //        guard let hash = components.queryItems?.first(where: { $0.name == "hash" })?.value else {
    //            print("Hash not provideed")
    //            return
    //        }
    
}


#Preview {
    ContentView()
        .environmentObject(LoginViewModel())

}
