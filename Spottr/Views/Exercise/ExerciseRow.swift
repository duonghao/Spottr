//
//  ExerciseView.swift
//  Spottr
//
//  Created by Hao Duong on 27/7/2023.
//

import SwiftUI

struct ExerciseRow: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var exercise: Exercise
    @State private var isExpanded: Bool = false
    var onTap: () -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            SetList(exercise: exercise)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.uName.capitalized)
                        .font(.headline)
                        .onTapGesture {
                            onTap()
                        }
                    if !isExpanded {
                        Text("Sets: \(String(exercise.setsArray.count))")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .disclosureGroupStyle(CustomDisclosureGroupStyle())
        .background(.thickMaterial)
        .background(exercise.isDone ? .green : .clear)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
    
    func addSet() {
        let newSet = ExerciseSet(context: moc)
        newSet.id = UUID()
        exercise.addToSets(newSet)
        
        save()
    }
    
    func deleteSet(at offsets: IndexSet) {
        for index in offsets {
            let set = exercise.setsArray[index]
            exercise.removeFromSets(set)
            moc.delete(set)
        }
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct ExerciseRow_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(1..<5, id: \.self) { _ in
                ExerciseRow(exercise: Exercise.example, onTap: {})
            }
           
            Spacer()
        }
        .padding()
    }
}
