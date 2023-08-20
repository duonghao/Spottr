//
//  CalendarView.swift
//  Spottr
//
//  Created by Hao Duong on 8/8/2023.
//

import SwiftUI

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()
}

struct CalendarView<DateView: View>: View {
    
    @Binding var month: Date
    let showHeaders: Bool
    let onHeaderAppear: (Date) -> Void
    let content: (Date) -> DateView
    private let daysInWeek = 7

    @Environment(\.sizeCategory) private var contentSize
    @Environment(\.calendar) private var calendar
    @State private var months: [Date] = []
    @State private var days: [Date: [Date]] = [:]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(months, id: \.self) { month in
                
                // Monthly title
                Section(header: title(for: month)) {
                    
                    // Weekday header
                    ForEach(days[month, default: []].prefix(7), id: \.timeIntervalSince1970, content: header)
                    
                    // Calendar
                    ForEach(days[month, default: []], id: \.self) { date in
                        if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                            content(date).id(date)
                        } else {
                            content(date).hidden()
                        }
                    }
                }
            }
        }
        .onAppear(perform: generateDates)
        .onChange(of: month) { _ in
            generateDates()
        }
    }
    
    private var columns: [GridItem] {
        let spacing: CGFloat = contentSize.isAccessibilityCategory ? 2 : 8
        return Array(repeating: GridItem(spacing: spacing), count: 7)
    }
    
    private func generateDates() {
        months = calendar.generateDates(
            inside: DateInterval(start: month, end: month),
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
        
        days = months.reduce(into: [:]) { current, month in
            guard
                let monthInterval = calendar.dateInterval(of: .month, for: month),
                let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
                let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
            else { return }
            
            current[month] = calendar.generateDates(
                inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
                matching: DateComponents(hour: 0, minute: 0, second: 0)
            )
        }
    }
    
    private func header(for date: Date) -> some View {
        let weekDayDateFormatter = DateFormatter()
        weekDayDateFormatter.dateFormat = "EEEEE"
        weekDayDateFormatter.calendar = calendar
        
        return Text(weekDayDateFormatter.string(from: date))
    }

    private func title(for month: Date) -> some View {
        Group {
            if showHeaders {
                Text(DateFormatter.monthAndYear.string(from: month))
                    .font(.title)
                    .padding()
            }
        }
        .onAppear { onHeaderAppear(month) }
    }
}
