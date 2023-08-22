//
//  PersistentController.swift
//  Spottr
//
//  Created by Hao Duong on 5/8/2023.
//

import CoreData
import Foundation

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        for a in 0..<3 {
            let program = Folder(context: controller.container.viewContext)
            program.id = UUID()
            program.name = "StrongLifts"
        
            for i in 0..<3 {
                let workout = Workout(context: controller.container.viewContext)
                workout.id = UUID()
                workout.name = "Workout \(i)"
                workout.isTemplate = true
                program.addToWorkouts(workout)
                
                for j in 0..<3 {
                    let exercise = Exercise(context: controller.container.viewContext)
                    exercise.id = UUID()
                    exercise.name = "Exercise \(j)"
                    exercise.exerciseType = ExerciseType(name: "Type \(j)", group: "Group \(j)")
                    workout.addToExercises(exercise)
                    
                    for k in 0..<3 {
                        let set = ExerciseSet(context: controller.container.viewContext)
                        set.id = UUID()
                        set.reps = Int16(10)
                        set.weight = 60
                        
                        exercise.addToSets(set)
                    }
                }
            }
        }
        
        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "FitnessTrackingModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error: Unable to save changes to CoreData.\n \(error.localizedDescription)")
            }
        }
    }
}
