//
//  SetRow.swift
//  Spottr
//
//  Created by Hao Duong on 5/8/2023.
//

import SwiftUI

struct SetRow: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var workout: Workout
    @ObservedObject var set: ExerciseSet
    @State private var setType: String
    @State private var weight: Double?
    @State private var reps: Int?
    
    static private let setTypes: [String] = ["W", "D", "F"]
    private var order: Int
    private var lastSet: ExerciseSet?
    private var exercise: Exercise
    
    init(exercise: Exercise, set: ExerciseSet, order: Int, lastSet: ExerciseSet?) {
        self.order = order
        self.lastSet = lastSet
        self.exercise = exercise
        
        _setType = State(initialValue: String(order))
        _set = ObservedObject(initialValue: set)
       
        if set.isValid {
            _weight = State(initialValue: set.weight)
            _reps = State(initialValue: Int(set.reps))
        }
    }
    
    var body: some View {
        HStack {
            column(content: nameView)
            column(content: lastSetView)
            column(content: weightView)
            column(content: repsView)
            
            GeometryReader { geo in
                Button {
                    toggleSet(set: set)
                } label: {
                    Label("Complete Set", systemImage: "checkmark")
                        .labelStyle(.iconOnly)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                .disabled(buttonDisabled)
            }
        }
        .padding(.vertical)
        .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(set.isDone ? .green.opacity(0.2) : .clear)
        .onDelete {
            remove(set: set, from: exercise)
        }
    }
    
    func column(content: () -> some View) -> some View {
        GeometryReaderView {
            content()
        }
    }
    
    func nameView() -> some View {
        Text("Set")
            .hidden()
            .overlay {
                Text(setType)
            }
            .onTapGesture {
                updateSetType()
            }
    }
    
    func lastSetView() -> some View {
        Text(lastSetString)
            .font(.headline)
    }
    
    func weightView() -> some View {
        TextField(lastSetWeight, value: $weight, format: .number)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .onChange(of: weight, perform: updateWeight)
    }
    
    func repsView() -> some View {
        TextField(lastSetReps, value: $reps, format: .number)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onChange(of: reps, perform: updateReps)
    }
    
    func updateWeight(_ weight: Double?) {
        guard let weight = weight else {
            return
        }
        workout.objectWillChange.send()
        exercise.objectWillChange.send()
        set.weight = weight
    }
    
    func updateReps(_ reps: Int?) {
        guard let reps = reps else {
            return
        }
        workout.objectWillChange.send()
        exercise.objectWillChange.send()
        set.reps = Int16(reps)
    }
    
    var validLastSet: Bool {
        guard let lastSet = lastSet else {
            return false
        }
        return (lastSet.weight >= 0 && lastSet.reps >= 0)
    }
    
    var buttonDisabled: Bool {
        if validLastSet {
            return false
        }
        return (weight == nil || reps == nil)
    }
    
    var lastSetWeight: String {
        guard let lastSet = lastSet else {
            return "-"
        }
        if lastSet.weight < 0 {
            return "-"
        }
        return "\(lastSet.weight)"
    }
    
    var lastSetReps: String {
        guard let lastSet = lastSet else {
            return "-"
        }
        if lastSet.reps < 0 {
            return "-"
        }
        return "\(lastSet.reps)"
    }
    
    var lastSetString: String {
        guard let lastSet = lastSet else {
            return "-"
        }
        if lastSet.reps < 0 || lastSet.weight < 0 {
            return "-"
        }
        if !lastSet.isDone {
            return "-"
        }
        return lastSetWeight + "x" + lastSetReps
    }
    
    func updateSetType() {
        if setType == String(order) {
            setType = Self.setTypes.first ?? String(order)
        } else {
            let nextIndex = (Self.setTypes.firstIndex(of: setType) ?? 0) + 1
            setType = nextIndex >= Self.setTypes.count ? String(order) : Self.setTypes[nextIndex]
        }
    }
    
    func toggleSet(set: ExerciseSet) {
        workout.objectWillChange.send()
        exercise.objectWillChange.send()
        
        if validLastSet && weight == nil && reps == nil {
            guard let lastSet = lastSet else {
                return
            }
            set.reps = lastSet.reps
            reps = Int(lastSet.reps)
            
            set.weight = lastSet.weight
            weight = lastSet.weight
        }
        
        set.isDone.toggle()
        save()
    }
    
    func remove(set: ExerciseSet, from exercise: Exercise) {
        exercise.removeFromSets(set)
        moc.delete(set)
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct SetRow_Previews: PreviewProvider {
    
    static var previews: some View {
        LazyVStack(spacing: 0) {
            ForEach(1..<5, id: \.self) { _ in
                SetRow(exercise: Exercise.example, set: ExerciseSet.example, order: 1, lastSet: ExerciseSet.example)
            }
        }
    }
}
