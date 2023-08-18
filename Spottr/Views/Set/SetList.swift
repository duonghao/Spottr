//
//  SetList.swift
//  Spottr
//
//  Created by Hao Duong on 14/8/2023.
//

import SwiftUI

struct SetList: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var exercise: Exercise
    private let headers: [HeaderItem] = [
        .init(title: "set"),
        .init(title: "last"),
        .init(title: "weight"),
        .init(title: "reps"),
        .init(title: "done")
    ]
    private let layout: [GridItem] = [
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible()),
        .init(.flexible())
    ]

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ForEach(headers) { header in
                    Text(header.title.capitalized)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            
            ForEach(Array(exercise.setsArray.enumerated()), id: \.offset) { index, exerciseSet in
                SetRow(exercise: exercise, set: exerciseSet, order: index + 1, lastSet: priorSet(from: index))
            }
            
            GridRow {
                Button {
                    withAnimation {
                        addSet()
                    }
                } label: {
                    Label("New set", systemImage: "plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                }
            }
            .gridCellColumns(5)
        }
        .padding(.top)
        .background(.black.opacity(0.1))
    }
    
    func addSet() {
        let newSet = ExerciseSet(context: moc)
        newSet.id = UUID()
        
        exercise.addToSets(newSet)
        
        save()
    }
    
    func priorSet(from index: Int) -> ExerciseSet? {
        index == 0 ? priorExercise?.setsArray.last : exercise.setsArray[index - 1]
    }
    
    var priorExercise: Exercise? {
        Exercise.getPriorExercise(exercise: exercise)
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

struct SetList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SetList(exercise: Exercise.example)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
