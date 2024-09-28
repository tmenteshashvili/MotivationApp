
import SwiftUI
import UserNotifications

struct Remainder: View {
    @AppStorage("isDarkMode") private var isDark = false
    @State private var nextView = false
    @StateObject private var notificationService = NotificationService()
    @State private var isPermissionGranted = false
    @State var howMany: Int
    @State var startTime: Date
    @State var endTime: Date
    
    
    
    var quotes: [Quote]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Do you want to get\n  daily reminders?")
                    .font(.system(size: 35, weight: .heavy))
                    .padding()
                
                
                Text("Every day at the same time you gonna receive\n a personal push notification with quotes you need.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack {
                    Text("How many")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            if howMany != 1 {
                                howMany -= 1
                            }
                        }, label: {
                            Image(systemName: "minus.square")
                                .padding()
                                .foregroundColor(Color.black)
                        })
                        
                        Text("\(howMany)X")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                        
                        
                        Button(action: {
                            if howMany != 15 {
                                howMany += 1
                            }
                        }, label: {
                            Image(systemName: "plus.square")
                                .padding()
                                .foregroundColor(Color.black)
                            
                        })
                    }
                }
                .padding(.vertical)
                
                Divider().frame(width: 350).background(Color("Logbuttondurk"))
                
                HStack {
                    DatePicker("Start at:", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                }
                .padding(.vertical)
                
                Divider().frame(width: 350).background(Color("Logbuttondurk"))
                
                HStack {
                    DatePicker("End at:", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                }
                .padding(.vertical)
                
                Divider().frame(width: 350).background(Color("Logbuttondurk"))
                Spacer()
                
                Button {
                    Task {
                        do {
                            let quotes = try await fetchQuotas()
                            
                            notificationService.scheduleAllNotifications(
                                from: startTime,
                                to: endTime,
                                count: howMany,
                                quotes: quotes
                            )
                            
                            nextView.toggle()
                            saveForNotifications()
                        } catch {
                            print("Error fetching quotes: \(error)")
                        }
                    }
                    
                } label: {
                    Text("Save")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color("Txtebackground"))
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("Logbuttondurk"))
                .cornerRadius(20)
                .padding(.horizontal)
                
            }
            .padding()
        }
        .navigationDestination(isPresented: $nextView) {
            Main()
        }
        .onAppear {
            notificationService.requestNotificationPermission { granted in
                isPermissionGranted = granted
                if !granted {
                    print("Notification permission not granted")
                }
            }
        }
        
        .environment(\.colorScheme, isDark ? .dark : .light)
        
    }
    func saveForNotifications() {
        UserDefaults.standard.set(howMany, forKey: "howMany")
        UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
    }
}


#Preview {
    Remainder(
        howMany: 3,
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        quotes: [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
    
}
