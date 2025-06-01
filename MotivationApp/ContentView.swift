
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject private var recoverVM = ResetPasswordViewModel()
    @State private var token: String?
    @State private var email: String?
    @State private var showResetPassword = false
    var quotes: [QuoteService.Quote]

    
    var body: some View {
        Group {
            if loginVM.isAuthenticated {
                if UserDefaults.standard.bool(forKey: "hasSetupReminders") {
                    MainView()
                        .onAppear {
                            UserDefaults.standard.set(0, forKey: "selectedTab")
                        }
                } else {
                    RemainderView(howMany: 3, quotes: [QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")
                                                      ])
                }
                
            } else {
                Welcome()
            }
        }
        .onAppear {
            
            if !UserDefaults.standard.bool(forKey: "hasSetupReminders") &&
                UserDefaults.standard.integer(forKey: "howMany") > 0 {
                UserDefaults.standard.set(true, forKey: "hasSetupReminders")
            }
            if loginVM.isAuthenticated && UserDefaults.standard.bool(forKey: "hasSetupReminders") {
                UserDefaults.standard.set(0, forKey: "selectedTab")
            }
        }
        
        .onOpenURL { url in
            print("App opened with URL: \(url.absoluteString )")
            handleDeepLink(url)
        }
        
        .sheet(isPresented: $showResetPassword) {
            if let token = token, let email = email {
                Text("About to show ResetPasswordView")
                    .onAppear {
                        print("Sheet appeared")
                    }
                ResetPasswordView(token: token, email: email)
            }
        }
        
        .onAppear {
            if UserDefaults.standard.bool(forKey: "justAuthenticated") {
                UserDefaults.standard.set(false, forKey: "justAuthenticated")
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
    ContentView(quotes: [QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
        .environmentObject(LoginViewModel())
    
}
