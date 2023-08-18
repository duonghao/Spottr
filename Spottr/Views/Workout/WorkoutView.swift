//
//  WorkoutView.swift
//  Spottr
//
//  Created by Hao Duong on 18/7/2023.
//

import SwiftUI

struct WorkoutView: View {
    
    @ObservedObject var workout: Workout
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @State private var showingFocusSheet: Bool = false
    @State private var showingSelectExercise: Bool = false
    @State private var selectedExercise: Exercise?
    @State private var selectedExercises: [ExerciseType] = []
    @State private var datePicked: Date
    @State private var timerEnabled: Bool = false
    @State private var selectedDent: PresentationDetent = .medium
    @State private var name: String = ""
    @State private var showingFinished = false
    @State private var hasStarted: Bool
    @State private var hasFinished: Bool
    
    init(workout: Workout) {
        self.workout = workout
        _hasStarted = State(initialValue: workout.hasStarted)
        _hasFinished = State(initialValue: workout.hasFinished)
        _datePicked = State(initialValue: workout.uEndDate)
        _selectedExercises = State(initialValue: getInitialSelectedExercises(workout: workout))
    }
    
    var body: some View {
        VStack {
            if workout.endDate != nil {
                DatePicker("End Date", selection: $datePicked, displayedComponents: .date)
                    .padding()
                    .datePickerStyle(.compact)
                    .onChange(of: datePicked, perform: updateEndDate)
                    .labelsHidden()
            }
            ScrollView {
                VStack {
                    ForEach(workout.exercisesArray) { exercise in
                        ExerciseRow(exercise: exercise) {
                            selectedExercise = exercise
                        }
                    }

                    addExerciseButton()
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .safeAreaInset(edge: .bottom) {
                if (hasStarted && !hasFinished) {
                    CurrentExercisePreviewView(workout: workout).transition(.move(edge: .bottom))
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .environmentObject(workout)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFinished) {
            DoneView(workout: workout)
        }
        .sheet(isPresented: $showingSelectExercise) {
            SelectExerciseView(selectedExercises: $selectedExercises)
                .onChange(of: selectedExercises, perform: updateWorkout)
        }
        .navigationTitle(workout.uName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button("Notes") {}
                    Spacer()
                    if (!hasStarted) {
                        Button(action: startWorkout) {
                            Text("Start")
                        }
                    }
                    else if (!hasFinished) {
                        Button("Finish", role: .destructive, action: finishWorkout)
                            .disabled(!hasStarted)
                    }
                }
                Divider()
            }
        }
        .onReceive(workout.objectWillChange) { newValue in
            if (workout.hasStarted && workout.allSetsFinished) {
                withAnimation(.easeOut) {
                    hasFinished = true
                }
            }
        }
    }
    
    func getInitialSelectedExercises(workout: Workout) -> [ExerciseType] {
        var selectedExercises: [ExerciseType] = []
        for exercise in workout.exercisesArray {
            selectedExercises.append(exercise.exerciseType)
        }
        return selectedExercises
    }
    
    func finishWorkout() {
        showingFinished = true
    }
    
    func updateEndDate(_ endDate: Date) {
        workout.endDate = endDate
        save()
    }
    
    func startWorkout() {
        if workout.isTemplate {
            // Make a new template
            let newTemplate = workout.copyEntireObjectGraph(context: moc) as? Workout
            newTemplate?.id = UUID()
        }
        
        if workout.startDate == nil {
            workout.startDate = Date.now
            workout.isTemplate = false
        }
        
        save()

        withAnimation {
            hasStarted = true
        }
    }
    
    func updateWorkout(selectedExercises: [ExerciseType]) -> Void {
        let exercisesToRemove = workout.exercisesArray.filter( { exercise in !selectedExercises.contains(where: {$0.self == exercise.exerciseType})} )
        for exerciseToRemove in exercisesToRemove {
            workout.removeFromExercises(exerciseToRemove)
            moc.delete(exerciseToRemove)
        }
        
        let exerciseTypesToAdd = selectedExercises.filter({ exerciseType in !workout.exercisesArray.contains(where: {$0.exerciseType == exerciseType})})
        for exerciseTypeToAdd in exerciseTypesToAdd {
            addExercise(exerciseType: exerciseTypeToAdd)
        }
        
        save()
    }
    
    func addExerciseButton() -> some View {
        Button {
            showingSelectExercise = true
        } label: {
            Label("New Exercise", systemImage: "plus")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        }
    }
    
    func addExercise(exerciseType: ExerciseType) {
        let newExercise = Exercise(context: moc)
        newExercise.id = UUID()
        newExercise.exerciseType = exerciseType
        workout.addToExercises(newExercise)
        save()
    }
    
    func updateExercise(exercise: Exercise, name: String) {
        exercise.name = name
        save()
    }
    
    func deleteExercise(exercise: Exercise) {
        workout.removeFromExercises(exercise)
        moc.delete(exercise)
        save()
    }
    
    func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            let exercise = workout.exercisesArray[index]
            workout.removeFromExercises(exercise)
            moc.delete(exercise)
        }
        save()
    }
    
    func moveExercise(from offsets: IndexSet, to: Int) {
        for index in offsets {
            let exercise = workout.exercisesArray[index]
            workout.removeFromExercises(exercise)
            workout.insertIntoExercises(exercise, at: to == 0 ? to : to - 1)
        }
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutView(workout: Workout.example)
        }
        
    }
}
