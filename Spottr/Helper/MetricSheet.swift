//
//  MetricSheet.swift
//  Spottr
//
//  Created by Hao Duong on 14/8/2023.
//

import Charts
import SwiftUI

struct RecordsView: View {
    
    var body: some View {
        List {
            Section("Records") {
                HStack {
                    Text("Weight")
                    Spacer()
                    Text("60")
                }
                HStack {
                    Text("1RM")
                    Spacer()
                    Text("120")
                }
                HStack {
                    Text("Volume")
                    Spacer()
                    Text("60")
                }
                HStack {
                    Text("Reps")
                    Spacer()
                    Text("60")
                }
            }
            .listRowInsets(EdgeInsets())
        }
        .listStyle(.plain)
    }
}

struct GraphView: View {
    
    var body: some View {
        Chart {
            LineMark(
                x: .value("Date", Date.now),
                y: .value("Weight", 60.0)
            )
            LineMark(
                x: .value("Date", Date.now.addingTimeInterval(86400)),
                y: .value("Weight", 80.0)
            )
            LineMark(
                x: .value("Date", Date.now.addingTimeInterval(2 * 86400)),
                y: .value("Weight", 75.0)
            )
        }
        .padding()
        .padding(.bottom)
    }
}

struct MetricSheet: View {
    
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.uName.capitalized)
                .font(.title)
            Text(exercise.uGroup.capitalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TabView {
                RecordsView()
                GraphView()
            }
            .tabViewStyle(.page)
            
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

struct MetricSheet_Previews: PreviewProvider {
    static var previews: some View {
        MetricSheet(exercise: Exercise.example)
    }
}
