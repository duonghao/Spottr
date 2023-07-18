//
//  ExerciseType.swift
//  Spottr
//
//  Created by Hao Duong on 11/8/2023.
//

import Foundation

struct ExerciseType: Identifiable, Codable, Equatable, Hashable {
    var id: String {
        self.name
    }
    var name: String
    var group: String
}
