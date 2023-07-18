//
//  Metric.swift
//  Spottr
//
//  Created by Hao Duong on 11/8/2023.
//

import Foundation

enum Metric: String, Identifiable, CaseIterable {
    var id: Self {
        return self
    }
    
    case weight = "weight"
    case e1RM = "e1RM"
    case volume = "volume"
    case sets = "sets"
}

extension Metric {
    static func calculateMetric(workout: Workout, exerciseType: ExerciseType, metric: Metric) -> Double? {
        let sets = workout.exercisesArray.first(where: { $0.exerciseType == exerciseType })?.setsArray
        
        switch metric {
            case .weight:
                return weight(sets: sets)
            case .e1RM:
                return e1RM(sets: sets)
            case .volume:
                return volume(sets: sets)
            case .sets:
                return reps(sets: sets)
        }
    }
    
    static func maxWeightSet(sets: [ExerciseSet]?) -> ExerciseSet? {
        sets?.max(by: {$0.weight < $1.weight})
    }
    
    static func weight(sets: [ExerciseSet]?) -> Double? {
        maxWeightSet(sets: sets)?.weight
    }
    
    static func e1RM(sets: [ExerciseSet]?) -> Double? {
        let set = maxWeightSet(sets: sets)
        guard
            let weight = set?.weight,
            let reps = set?.reps
        else {
            return nil
        }
        
        return (weight / ( 1.0278 - 0.0278 * Double(reps)))
    }
    
    static func volume(sets: [ExerciseSet]?) -> Double? {
        sets?.reduce(0, { x, y in
            x + y.weight * Double(y.uReps)
        })
    }
    
    static func reps(sets: [ExerciseSet]?) -> Double? {
        sets?.reduce(0, { x, y in
            x + Double(y.uReps)
        })
    }
}
