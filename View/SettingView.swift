

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var loginVM: LoginViewModel
    
    var body: some View {
        NavigationStack {
//            VStack(alignment: .leading, spacing: 10) {
////                HStack {
////                    Button(action: {
////                        // some haptic thing
////                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
////                        impactMed.impactOccurred()
////                        
////                        self.dismiss()
////                    }) {
////                        Text("Close")
////                            .foregroundColor(Color.primary)
////                            .font(.system(size: 18, weight: .regular, design: .rounded))
////                            .padding(.horizontal, 20)
////                            .padding(.top, 20)
////                    }
////                    Spacer()
//                }
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    SettingsRow(imageName: "bell", title: "Notifications") {
                        self.settingsViewModel.showRemainder = true
                    }
                    .sheet(isPresented: $settingsViewModel.showRemainder) {
                        RemainderView(howMany: settingsViewModel.howMany, startTime: settingsViewModel.startTime, endTime:  settingsViewModel.endTime, quotes: [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    
                    Divider()
                    
                    Button {
                        loginVM.signout()
                    } label: {
                        Text("Sign out")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            
                        
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color("SystemBlueLight"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    
                }
                .padding()
            }
        }
        
    }



#Preview {
    SettingView()
        .environmentObject(LoginViewModel())

}
