import SwiftUI
import UserNotifications

struct RemainderView: View {
    @StateObject private var viewModel = QuoteViewModel()
    @State private var nextView = false
    @StateObject private var notificationService = NotificationService()
    @State private var isPermissionGranted = false
    @State var howMany: Int
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var navigationInProgress = false
    @State private var showPermissionAlert = false
    var quotes: [QuoteService.Quote]
    
    init(howMany: Int, quotes: [QuoteService.Quote]) {
        self._howMany = State(initialValue: UserDefaults.standard.integer(forKey: "howMany") > 0 ?
                              UserDefaults.standard.integer(forKey: "howMany") : howMany)
        
        let startTimeInterval = UserDefaults.standard.double(forKey: "startTime")
        let endTimeInterval = UserDefaults.standard.double(forKey: "endTime")
        
        if startTimeInterval > 0 {
            self._startTime = State(initialValue: Date(timeIntervalSince1970: startTimeInterval))
        } else {
            var components = DateComponents()
            components.hour = 12
            components.minute = 0
            self._startTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
        }
        
        if endTimeInterval > 0 {
            self._endTime = State(initialValue: Date(timeIntervalSince1970: endTimeInterval))
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            self._endTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
        }
        
        self.quotes = quotes
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Do you want to get\n  daily reminders?")
                .font(.system(size: 35, weight: .heavy))
                .padding()
            
            Text("Every day at specific times you will receive\npersonal push notifications with motivational quotes.")
                .multilineTextAlignment(.center)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Text("How many")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            if howMany > 1 {
                                howMany -= 1
                            }
                        }, label: {
                            Image(systemName: "minus.square")
                                .padding()
                                .foregroundColor(.secondary)
                        })
                        
                        Text("\(howMany)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            if howMany < 15 {
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
                
                if !isValidTimeRange {
                    Text("End time must be after start time")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding()
        
        VStack {
            Button {
                saveNotificationSettings()
            } label: {
                HStack {
                    if navigationInProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                    }
                    
                    Text("Save")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(isValidTimeRange ? Color("SystemBlueLight") : Color.gray)
            .cornerRadius(20)
            .padding(.horizontal)
            .disabled(navigationInProgress || !isValidTimeRange)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("RemainderView appeared")
            checkNotificationPermission()
        }
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Skip", role: .cancel) {
                proceedToMainView()
            }
        } message: {
            Text("To receive motivational quotes, please enable notifications in Settings.")
        }
    }
    
    private var isValidTimeRange: Bool {
        return endTime > startTime
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.isPermissionGranted = true
                case .denied:
                    self.showPermissionAlert = true
                case .notDetermined:
                    self.requestNotificationPermission()
                @unknown default:
                    self.requestNotificationPermission()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        notificationService.requestNotificationPermission { granted in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if !granted {
                    self.showPermissionAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // ✅ FIXED: Use new pagination method
    private func saveNotificationSettings() {
        guard !navigationInProgress else { return }
        navigationInProgress = true
        
        Task {
            do {
                saveForNotifications()
                
                if self.isPermissionGranted {
                    await notificationService.scheduleAllNotificationsWithPagination(
                        from: startTime,
                        to: endTime,
                        count: howMany
                    )
                    print("✅ Notifications scheduled with pagination")
                } else {
                    print("⚠️ Notifications not scheduled - permission not granted")
                }
                
                UserDefaults.standard.set(true, forKey: "hasSetupReminders")
                UserDefaults.standard.set(0, forKey: "selectedTab")
                
                await MainActor.run {
                    proceedToMainView()
                }
                
            } catch {
                await MainActor.run {
                    self.navigationInProgress = false
                    print("❌ Error setting up notifications: \(error)")
                }
            }
        }
    }
    
    private func proceedToMainView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
                window.rootViewController = UIHostingController(rootView: MainView())
                window.makeKeyAndVisible()
            }
        }
    }
    
    func saveForNotifications() {
        print("💾 Saving notification settings:")
        print("   How many: \(howMany)")
        print("   Start time: \(formatTime(startTime))")
        print("   End time: \(formatTime(endTime))")
        
        UserDefaults.standard.set(howMany, forKey: "howMany")
        UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
        UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
        UserDefaults.standard.synchronize()
    }
}

#Preview {
    RemainderView(
        howMany: 4,
        quotes: [QuoteService.Quote(id: 1, category: "Motivational", type: "text", author: "Benjamin Franklin", content: "Let all your things have their places; let each part of your business have its time.")]
    )
}
