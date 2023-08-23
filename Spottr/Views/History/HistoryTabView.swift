//
//  HistoryView.swift
//  Spottr
//
//  Created by Hao Duong on 8/8/2023.
//

import SwiftUI

struct HistoryTabView: View {
    
    private enum Views: String, CaseIterable, Identifiable {
        var id: Self {
            return self
        }
        
        case list = "list", calendar = "calendar"
    }
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor.init(key: "endDate", ascending: false)], predicate: NSPredicate(format: "endDate != nil")) var completedWorkouts: FetchedResults<Workout>
    @State private var month: Date = Date.now
    @State private var selectedView: Views = .list
    
    // MARK: - Views
    
    var body: some View {
        if completedWorkouts.isEmpty {
            placeHolder
        } else {
            VStack {
                viewPicker
                TabView(selection: $selectedView) {
                    views
                }
            }
            .padding(.horizontal)
        }
    }
    
    var placeHolder: some View {
        VStack {
            Text("Can't have any completed workouts if you haven't started any.")
            Text("Start one today!")
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
    
    var viewPicker: some View {
        Picker("View Selection", selection: $selectedView) {
            ForEach(Views.allCases) { view in
                Text(view.rawValue.capitalized).tag(view)
            }
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    var views: some View {
        list.tag(Views.list)
        calendar.tag(Views.calendar)
    }
    
    var list: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        let monthlyWorkouts = sortedByMonth(workouts: completedWorkouts)
        
        return ScrollView {
            VStack {
                ForEach(Array(monthlyWorkouts.keys), id: \.self) { month in
                    HStack {
                        Text(dateFormatter.string(from: month))
                            .bold()
                        Spacer()
                        Text("\(monthlyWorkouts[month]?.count ?? 0) Workouts")
                            .foregroundColor(.secondary)
                    }
                    Divider()
                    ForEach(monthlyWorkouts[month] ?? []) { workout in
                        HStack(spacing: 8) {
                            date(workout.uEndDate)
                            WorkoutNavView(workout: workout)
                        }
                    }
                    
                }
            }
        }
    }
    
    func date(_ date: Date) -> some View {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM"
        let month: String = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd"
        let day: String = dateFormatter.string(from: date)
        
        return VStack(alignment: .center, spacing: 8) {
            Text(month)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(day)
                .bold()
        }
        .padding()
        .frame(maxHeight: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .stroke(.primary, lineWidth: 1)
        }
    }
    
    var calendar: some View {
        var startDate = completedWorkouts.first?.uEndDate ?? Date.now
        var endDate = completedWorkouts.last?.uEndDate ?? Date.now
        
        if startDate > endDate {
            swap(&startDate, &endDate)
        }
        
        return ScrollView {
            CalendarView(
                interval: .init(start: startDate, end: endDate),
                showHeaders: true,
                onHeaderAppear: { _ in }) { date in
                    DateMarker(
                        date: date,
                        numberOfDots: completedWorkoutsByEndDate(date).count,
                        fillColor: .accentColor,
                        emptyColor: .clear
                    )
                }
                .padding(.top)
        }
    }
    
    var monthAdjuster: some View {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMMM"

        return HStack {
            previousMonthAdjuster
            Spacer()
            Text(dateFormatterGet.string(from: month))
                .font(.headline)
            Spacer()
            nextMonthAdjuster
        }
    }
    
    // MARK: - Functions
    
    func sortedByMonth(workouts: FetchedResults<Workout>) -> [Date: [Workout]] {
        guard var startDate = workouts.first?.uEndDate,
              var endDate = workouts.last?.uEndDate
        else {
            return [:]
        }
        
        if startDate > endDate {
            swap(&startDate, &endDate)
        }
        
        let months = Date.getMonthAndYearBetween(from: startDate, to: endDate)
            .reduce(into: [:]) { current, month in
                current[month] = Array<Workout>()
            }
        
        let sorted = workouts
            .reduce(into: months) { current, workout in
                current[workout.uEndDate.startOfMonth()]?.append(workout)
            }
    
        return sorted
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

struct HistoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTabView()
    }
}
