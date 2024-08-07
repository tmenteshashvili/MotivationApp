
import SwiftUI

struct Remainder: View {
    @State private var counter: Int = 10
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    
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
                            if counter > 0 {
                                counter -= 1
                            }
                        }, label: {
                            Image(systemName: "minus.circle")
                                .offset(x: 30)
                        })
                        
                        Text("\(counter)X")
                            .fontWeight(.semibold)
                            .frame(minWidth: 36)
                            .offset(x: 40)
                        
                        
                        Button(action: {
                            if counter < 100 {
                                counter += 1
                            }
                        }, label: {
                            Image(systemName: "plus.circle")
                                .offset(x: 50)
                            
                        })
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    
                    HStack {
                        DatePicker("Start at:", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 20))
                            .offset(x: 5)
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    
                    HStack {
                        DatePicker("End at:", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .font(.system(size: 20))
                            .offset(x: 5)
                        
                        
                    }
                    .padding(.vertical)
                    
                    Divider().frame(width: 350).background(Color("Logbuttondurk"))
                    Spacer()
                    
                    Button {
                        
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
            
        }
    }
}

#Preview {
    Remainder()
}
