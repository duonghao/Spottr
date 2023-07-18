//
//  SelectExerciseView.swift
//  Spottr
//
//  Created by Hao Duong on 11/8/2023.
//

import SwiftUI

struct SelectExerciseView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedExercises: [ExerciseType]
    private let exercisesList: [ExerciseType] = Bundle.main.decode(file: "exercises.json")
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List(filteredExerciseList) { exerciseType in
                Button {
                    updateSelection(exerciseType: exerciseType)
                } label: {
                    HStack {
                        Text(exerciseType.name.capitalized)
                        Spacer()
                        if alreadySelected(exerciseType: exerciseType) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
        
    }
    
    var filteredExerciseList: [ExerciseType] {
        if searchText.isEmpty {
            return exercisesList
        }
        return exercisesList.filter({ $0.name.localizedCaseInsensitiveContains(searchText)})
    }
    
    func alreadySelected(exerciseType: ExerciseType) -> Bool {
        selectedExercises.contains(exerciseType)
    }
    
    func updateSelection(exerciseType: ExerciseType) -> Void {
        if alreadySelected(exerciseType: exerciseType) {
            selectedExercises.removeAll(where: { $0 == exerciseType })
        } else {
            selectedExercises.append(exerciseType)
        }
    }
}

struct SelectExerciseView_Previews: PreviewProvider {
    @State static private var selectedExercises: [ExerciseType] = []
    
    static var previews: some View {
        NavigationStack {
            SelectExerciseView(selectedExercises: $selectedExercises)
        }
    }
}
