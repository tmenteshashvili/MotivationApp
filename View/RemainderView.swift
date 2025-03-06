
import SwiftUI
import UserNotifications

struct RemainderView: View {
    @State private var nextView = false
    @StateObject private var notificationService = NotificationService()
    @State private var isPermissionGranted = false
    @State var howMany: Int
    @State private var startTime: Date = {
            var components = DateComponents()
            components.hour = 12
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }()
        @State private var endTime: Date = {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }()


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
                    .foregroundColor(.secondary)
                
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
                                .foregroundColor(.secondary)
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
                                .foregroundColor(.secondary)
                            
                        })
                    }
                }
                .padding(.vertical)
                
                Divider().frame(width: 380).background(Color("SystemGrayLight"))
                
                HStack {
                    DatePicker("Start at:", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                }
                .padding(.vertical)
                
                Divider().frame(width: 380).background(Color("SystemGrayLight"))
                
                HStack {
                    DatePicker("End at:", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                }
                .padding(.vertical)
                
                Divider().frame(width: 380).background(Color("SystemGrayLight"))
                Spacer()
                
            }
            .padding()
            
            VStack {
                Button {
                    Task {
                        do {
                            let quotes = try await fetchQuotes()
                            
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
                        .foregroundStyle(.white)
                    
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color("SystemBlueLight"))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .navigationDestination(isPresented: $nextView) {
            MainView()
        }
        .onAppear {
            notificationService.requestNotificationPermission { granted in
                isPermissionGranted = granted
                if !granted {
                    print("Notification permission not granted")
                }
            }
        }
        
    }
    func saveForNotifications() {
        UserDefaults.standard.set(howMany, forKey: "howMany")
        UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
    }
}


#Preview {
    RemainderView(
        howMany: 5,
        quotes: [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
    
}
