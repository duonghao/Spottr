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
                CalendarView(
                    interval: DateInterval(start: Date.now, end: Calendar.current.date(byAdding: .day, value: 2, to: Date.now)!),
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
    
    func completedWorkoutsByEndDate(_ endDate: Date) -> [Workout] {
        completedWorkouts.filter { Calendar.current.isDate($0.endDate!, equalTo: endDate, toGranularity: .day) }
    }
    
    func save() {
        PersistenceController.shared.save()
    }
    
}
