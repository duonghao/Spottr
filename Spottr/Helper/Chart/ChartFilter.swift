//
//  ChartFilter.swift
//  Spottr
//
//  Created by Hao Duong on 11/8/2023.
//

import Foundation

struct ChartFilter: Identifiable, Hashable {
    let id = UUID()
    var exerciseType: ExerciseType
    var isOn: Bool
}
