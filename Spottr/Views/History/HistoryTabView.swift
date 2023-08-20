//
//  HistoryView.swift
//  Spottr
//
//  Created by Hao Duong on 8/8/2023.
//

import SwiftUI

struct HistoryTabView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "endDate != nil")) var completedWorkouts: FetchedResults<Workout>
    @State var month: Date = Date.now
    
    var body: some View {
        if completedWorkouts.isEmpty {
            VStack {
                Text("Can't have any completed workouts if you haven't started any.")
                Text("Start one today!")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        } else {
            VStack {
                header
                CalendarView(
                    month: $month,
                    showHeaders: false,
                    onHeaderAppear: { _ in }) { date in
                        DateMarker(
                            date: date,
                            numberOfDots: completedWorkoutsByEndDate(date).count,
                            fillColor: .yellow,
                            emptyColor: .clear
                        )
                    }
                    .padding(.top)
                    .background(RoundedRectangle(cornerRadius: .defaultCornerRadius).fill(.thinMaterial).shadow(radius: .defaultShadowRadius))
                
                VStack {
                    ForEach(completedWorkouts) { workout in
                        WorkoutNavView(workout: workout)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    var header: some View {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMMM"

        return HStack {
            previousMonthAdjuster
            Spacer()
            Text(dateFormatterGet.string(from: month))
            Spacer()
            nextMonthAdjuster
        }
    }
    
    func monthAdjuster(by: Int) -> some View {
        let title = (by <= 0 ? "Previous" : "Next") + "Month"
        let symbol = "arrow." + (by <= 0 ? "left" : "right")
        
        return Button {
            month = monthAdjuster(by: by, on: month)
        } label: {
            Label(title, systemImage: symbol)
                .labelStyle(.iconOnly)
        }
    }
    
    var previousMonthAdjuster: some View {
        monthAdjuster(by: -1)
    }
    
    var nextMonthAdjuster: some View {
        monthAdjuster(by: 1)
    }
    
    func monthAdjuster(by month: Int, on date: Date) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: date)!
    }
    
    func completedWorkoutsByEndDate(_ endDate: Date) -> [Workout] {
        completedWorkouts.filter { Calendar.current.isDate($0.endDate!, equalTo: endDate, toGranularity: .day) }
    }
    
    func save() {
        PersistenceController.shared.save()
    }
    
}
