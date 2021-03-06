//
//  ContentView.swift
//  BetterRest
//
//  Created by Di Wu on 2021-12-05.
//

import SwiftUI
import CoreML

// custom container
struct AwesomeStack<Content: View>: View {
    @ViewBuilder var content: ()-> Content
    var body: some View {
        Section {
            content()
        }
    }
}

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static private var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                AwesomeStack {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Wake up time", selection: $wakeUp, displayedComponents:[.hourAndMinute])
                        .labelsHidden()
                }
                
                AwesomeStack {
                    Text("Desired Amount of sleep?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                AwesomeStack {
                    Picker("Choose Coffee Amount", selection: $coffeeAmount) {
                        ForEach(1..<21) { Text("\($0) \($0 == 1 ? "Cup" : "Cups")")}
                    }
                    .font(.headline)
                }
                
                Text("\(calculateBedTime)")
            }
            .navigationTitle("Better Rest")
        }
    }
    
    private var calculateBedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration:  config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "An Error occured!"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
