//
//  Date.swift
//  Spottr
//
//  Created by Hao Duong on 23/8/2023.
//

import Foundation

extension Date {
    
    func startOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    static func getMonthAndYearBetween(from start: Date, to end: Date) -> [Date] {
        var allDates: [Date] = []
        guard start < end else { return allDates }
        
        let calendar = Calendar.current
        let month = calendar.dateComponents([.month], from: start, to: end).month ?? 0
        
        for i in 0...month {
            if let date = calendar.date(byAdding: .month, value: i, to: start) {
                allDates.append(date.startOfMonth())
            }
        }
        return allDates
    }
    
}
