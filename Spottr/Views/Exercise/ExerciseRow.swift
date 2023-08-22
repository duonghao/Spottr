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
    let onTap: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Views
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            SetList(exercise: exercise)
        } label: {
            label()
        }
        .disclosureGroupStyle(CustomDisclosureGroupStyle(padding: 16, onDelete: onDelete))
        .background(.thickMaterial)
        .background(exercise.isDone ? .green : .clear)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
    
    @ViewBuilder
    func label() -> some View {
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
            Spacer()
        }
    }
}

struct ExerciseRow_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(1..<5, id: \.self) { _ in
                ExerciseRow(exercise: Exercise.example, onTap: {}, onDelete: {})
            }
            Spacer()
        }
    }
}
