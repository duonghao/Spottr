//
//  ModelExtensions.swift
//  Spottr
//
//  Created by Hao Duong on 13/8/2023.
//

import CoreData
import Foundation

extension Folder {
    var uName: String {
        name ?? ""
    }
    
    var workoutsArray: [Workout] {
        return (workouts?.array ?? []) as! [Workout]
    }
    
    static var example: Folder {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        
        return (results?.first!)!
    }
    
    static var defFolderName: String {
        "My Templates"
    }
    
    static var defaultFolder: Folder {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", defFolderName)
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        
        if let defFolder = results?.first {
            return defFolder
        } else {
            let context = PersistenceController.shared.container.viewContext
            
            let newFolder = Folder(context: context)
            newFolder.id = UUID()
            newFolder.name = defFolderName
            
            PersistenceController.shared.save()
            
            return newFolder
        }
    }
}

extension Workout {
    
    var uid: String {
        id?.uuidString ?? UUID().uuidString
    }
    
    var uName: String {
        name ?? ""
    }
    
    var exercisesArray: [Exercise] {
        return (exercises?.array ?? []) as! [Exercise]
    }
    
    var isDone: Bool {
        exercisesArray.allSatisfy({ $0.isDone })
    }
    
    var uStartDate: Date {
        startDate ?? Date.now
    }
    
    var uEndDate: Date {
        endDate ?? Date.now
    }
    
    var hasStarted: Bool {
        startDate != nil
    }
    
    var hasFinished: Bool {
        endDate != nil
    }
    
    var currentExercise: Exercise? {
        exercisesArray.first(where: { !$0.isDone })
    }
    
    var uniqueExerciseGroups: [String] {
        let groups: [String] = self.exercisesArray.map({$0.exerciseType.group})
        return Array(Set(groups))
    }
    
    static var example: Workout {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        
        return (results?.first!)!
    }
    
    private func durationBetween(from: Date, to: Date) -> String {
        let diffs = Calendar.current.dateComponents([.hour, .minute, .second], from: from, to: to)
        return String(format: "%02d:%02d:%02d", diffs.hour!, diffs.minute!, diffs.second!)
    }
    
    var duration: String {
        durationBetween(from: self.uStartDate, to: self.uEndDate)
    }
    
    var volume: Double {
        exercisesArray.flatMap({ $0.setsArray }).reduce(0) { partialResult, exerciseSet in
            partialResult + (exerciseSet.weight * Double(exerciseSet.reps))
        }
    }
    
    var setsDone: Int {
        exercisesArray.flatMap({ $0.setsArray }).reduce(0) { partialResult, exerciseSet in
            partialResult + (exerciseSet.isDone ? 1 : 0)
        }
    }
    
    var allSetsFinished: Bool {
        exercisesArray.flatMap({ $0.setsArray }).allSatisfy({ $0.isDone })
    }
}

extension Exercise {
    
    var uid: String {
        id?.uuidString ?? UUID().uuidString
    }
    
    var uName: String {
        name ?? ""
    }
    
    var uGroup: String {
        group ?? ""
    }
    
    var setsArray: [ExerciseSet] {
        return (sets?.array ?? []) as! [ExerciseSet]
    }
    
    var isDone: Bool {
        setsArray.allSatisfy({ $0.isDone })
    }
    
    var currentSet: ExerciseSet? {
        setsArray.first(where: { !$0.isDone })
    }
    
    var exerciseType: ExerciseType {
        set {
            self.name = newValue.name
            self.group = newValue.group
        }
        get {
            return ExerciseType(name: self.uName, group: self.uGroup)
        }
    }
    
    static func getPriorExercise(exercise: Exercise) -> Exercise? {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "isTemplate == NO")
        
        guard let results = try? context.fetch(fetchRequest) else {
            return nil
        }
        
        let exercises = results.flatMap({ $0.exercisesArray }).filter({ $0.exerciseType == exercise.exerciseType })
        
        guard let index = exercises.firstIndex(of: exercise) else {
            return nil
        }
        
        if index + 1 >= exercises.count {
            return nil
        }
        
        return exercises[index + 1]
    }
    
    static var example: Exercise {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        
        return (results?.first!)!
    }
}

extension ExerciseSet {
    var uReps: Int {
        Int(reps)
    }
    
    var isValid: Bool {
        reps > 0 && weight > 0
    }
    
    static var example: ExerciseSet {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<ExerciseSet> = ExerciseSet.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        
        return (results?.first!)!
    }
}
