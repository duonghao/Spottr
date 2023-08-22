//
//  AddWorkoutSheet.swift
//  Spottr
//
//  Created by Hao Duong on 22/8/2023.
//

import SwiftUI

struct AddWorkoutSheet: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    let onSave: (Workout) -> Void
     
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Dimiss") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save", action: save).disabled(name.isEmpty) }
            }
        }
    }
    
    func save() {
        let newWorkout = Workout(context: moc)
        newWorkout.id = UUID()
        newWorkout.name = name
        newWorkout.isTemplate = false
        
        newWorkout.startDate = Date.now
        
        dismiss()
        
        onSave(newWorkout)
    }
}

struct AddWorkoutSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutSheet(onSave: { _ in })
    }
}
