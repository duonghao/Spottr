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
    @State private var allSetsFinished: Bool
    @State private var dragging: Exercise?
    var onStart: ((Workout, Workout) -> Void)?
    
    init(workout: Workout, onStart: ((Workout, Workout) -> Void)? = nil) {
        self.workout = workout
        self.onStart = onStart
        _hasStarted = State(initialValue: workout.hasStarted)
        _hasFinished = State(initialValue: workout.hasFinished)
        _allSetsFinished = State(initialValue: workout.allSetsFinished)
        _datePicked = State(initialValue: workout.uEndDate)
        _selectedExercises = State(initialValue: getSelected(workout: workout))
    }
    
    var body: some View {
        VStack {
            if workout.endDate != nil {
                endDateChanger
            }
            exercises
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .safeAreaInset(edge: .bottom) {
                    if (hasStarted && !hasFinished) {
                        CurrentExercisePreviewView(workout: workout).transition(.move(edge: .bottom))
                    }
                }
            Spacer()
        }
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
                buttonStack
            }
        }
        .onReceive(workout.objectWillChange) { newValue in
            if (workout.hasStarted && workout.allSetsFinished) {
                withAnimation(.easeOut) {
                    allSetsFinished = true
                }
            }
        }
    }
    
    var endDateChanger: some View {
        DatePicker("End Date", selection: $datePicked, displayedComponents: .date)
            .padding()
            .datePickerStyle(.compact)
            .onChange(of: datePicked, perform: updateEndDate)
            .labelsHidden()
    }
    
    var exercises: some View {
        ScrollView {
            VStack {
                ForEach(workout.exercisesArray) { exercise in
                    ExerciseRow(exercise: exercise) {
                        selectedExercise = exercise
                    } onDelete: {
                        withAnimation(.spring()) {
                            delete(exercise)
                        }
                    }
                    .draggable(exercise.uid) {
                        dragPreview(exercise: exercise)
                    }
                    .dropDestination(for: String.self) { _, _ in
                        dragging = nil
                        return false
                    } isTargeted: { status in
                        if let dragging, status, dragging != exercise {
                            move(from: dragging, to: exercise, in: workout)
                        }
                    }
                }
                addExerciseButton()
            }
            .animation(.spring(), value: workout.exercisesArray)
        }
    }
    
    var buttonStack: some View {
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
    }
    
    @ViewBuilder
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
    
    @ViewBuilder func dragPreview(exercise: Exercise) -> some View {
        EmptyView()
            .frame(width: 1, height: 1)
            .onAppear {
                dragging = exercise
            }
    }
    
    func delete(_ exercise: Exercise) {
        selectedExercises.removeAll(where: {$0 == exercise.exerciseType})
        workout.removeFromExercises(exercise)
        moc.delete(exercise)
        save()
    }
    
    func move(from source: Exercise, to destination: Exercise, in workout: Workout) {
        guard
            let sourceIndex = workout.exercisesArray.firstIndex(of: source),
            let destinationIndex = workout.exercisesArray.firstIndex(of: destination)
        else {
            return
        }
        workout.removeFromExercises(at: sourceIndex)
        workout.insertIntoExercises(source, at: destinationIndex)
    }
    
    func getSelected(workout: Workout) -> [ExerciseType] {
        workout.exercisesArray.map({ $0.exerciseType })
    }
    
    func finishWorkout() {
        hasFinished = true
        showingFinished = true
    }
    
    func updateEndDate(_ endDate: Date) {
        workout.endDate = endDate
        save()
    }
    
    func startWorkout() {
        if workout.isTemplate {
            let newTemplate = workout.copyEntireObjectGraph(context: moc) as? Workout
            guard let newTemplate = newTemplate else {
                return
            }
            newTemplate.id = UUID()
            onStart?(workout, newTemplate)
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
    
    func addExercise(exerciseType: ExerciseType) {
        let newExercise = Exercise(context: moc)
        newExercise.id = UUID()
        newExercise.exerciseType = exerciseType
        workout.addToExercises(newExercise)
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
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutView(workout: Workout.example, onStart: { _, _ in })
        }
        
    }
}
