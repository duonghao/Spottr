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
    @State var setType: String
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
            GeometryReaderView {
                Text("Set")
                    .hidden()
                    .overlay {
                        Text(setType)
                    }
                    .onTapGesture {
                        updateSetType()
                    }
            }
            GeometryReaderView {
                Text(lastSetString)
                    .font(.headline)
                    .fixedSize()
            }
            GeometryReaderView {
                TextField(lastSetWeight, value: $weight, format: .number)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .onChange(of: weight, perform: updateWeight)
            }
            GeometryReaderView {
                TextField(lastSetReps, value: $reps, format: .number)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onChange(of: reps, perform: updateReps)
            }
            GeometryReaderView {
                Button {
                    toggleSet(set: set)
                } label: {
                    Label("Complete Set", systemImage: "checkmark")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.plain)
                .disabled(buttonDisabled)
            }
        }
        .background(set.isDone ? .green.opacity(0.2) : .clear)
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
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct SetRow_Previews: PreviewProvider {

    static var previews: some View {
        List(1..<3, id: \.self) { _ in
            SetRow(exercise: Exercise.example, set: ExerciseSet.example, order: 1, lastSet: ExerciseSet.example)
                .listRowInsets(EdgeInsets())
        }
    }
}
