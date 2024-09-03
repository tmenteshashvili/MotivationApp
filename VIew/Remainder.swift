
import SwiftUI
import UserNotifications

struct Remainder: View {
    @ObservedObject var settings = ReminderSettings()
    @State private var nextView = false
    @StateObject private var notificationService = NotificationService()
    @State private var isPermissionGranted = false
    
    
    var quotes: [Quote]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Ellipse1")
                    .offset(x: 120, y: -340)
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("back"))
                    .frame(width: 380, height: 300)
                    .offset(y: 110)
                
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
                    
                    HStack(spacing: 20) {
                        Text("How many")
                            .font(.system(size: 20))
                            .offset(x: -60)
                        
                        
                        Button(action: {
                            if settings.counter > 1 {
                                settings.counter -= 1
                            }
                        }, label: {
                            Image(systemName: "minus.circle")
                                .offset(x: 30)
                        })
                        
                        Text("\(settings.counter)X")
                            .fontWeight(.semibold)
                            .frame(minWidth: 36)
                            .offset(x: 40)
                        
                        
                        Button(action: {
                            if settings.counter < 100 {
                                settings.counter += 1
                            }
                        }, label: {
                            Image(systemName: "plus.circle")
                                .offset(x: 50)
                            
                        })
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    
                    HStack {
                        DatePicker("Start at:", selection: $settings.startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 20))
                            .offset(x: 5)
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    
                    HStack {
                        DatePicker("End at:", selection: $settings.endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 20))
                            .offset(x: 5)
                        
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    Spacer()
                    
                    Button {
                        Task {
                            do {
                                let quotes = try await fetchQuotas()
                                
                                notificationService.scheduleAllNotifications(
                                    from: settings.startTime,
                                    to: settings.endTime,
                                    count: settings.counter,
                                    quotes: quotes
                                )
                                
                                nextView.toggle()
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
            
        }
    }
    
}

#Preview {
    Remainder(quotes: [Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")])
}
