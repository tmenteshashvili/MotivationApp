
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject private var recoverVM = ResetPasswordViewModel()
    @State private var token: String?
    @State private var email: String?
    @State private var showResetPassword = false
   
    var body: some View {
        NavigationStack {
            VStack {
                Welcome()
            }
        }
        
        .onOpenURL { url in
            print("App opened with URL: \(url.absoluteString )")
            handleDeepLink(url)
        }
//        .onAppear {
//                print("ContentView appeared")
//            }
//            .onChange(of: showResetPassword) { newValue in
//                print("showResetPassword changed to: \(newValue)")
//            }
        .sheet(isPresented: $showResetPassword) {
            if let token = token, let email = email {
                Text("About to show ResetPasswordView")
                               .onAppear {
                                   print("Sheet appeared")
                               }
                ResetPasswordView(token: token, email: email)
            }
        }
    }
    
    
     func handleDeepLink(_ url: URL) {
    
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("URL Components could not be created")
            return
        }
        print("Scheme: \(components.scheme ?? "nil")")
        print("Host: \(components.host ?? "nil")")
        print("Query Items: \(components.queryItems ?? [])")
        
        if components.scheme == "motivationapp" && components.host == "reset-password" {
            token = components.queryItems?.first(where: { $0.name == "token" })?.value
            email = components.queryItems?.first(where: { $0.name == "email" })?.value
            
            print("Extracted Token: \(token ?? "nil")")
            print("Extracted Email: \(email ?? "nil")")
            
            if token != nil && email != nil  {
                DispatchQueue.main.async {
                    showResetPassword = true
                    print("Set showResetPassword to true")
                }
            } else {
                print("Missing token or email")
            }
        }
        
    }
}
    
#Preview {
    ContentView()
        .environmentObject(LoginViewModel())
    
}
