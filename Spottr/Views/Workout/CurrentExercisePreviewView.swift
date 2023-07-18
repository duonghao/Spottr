//
//  CurrentExercisePreviewView.swift
//  Spottr
//
//  Created by Hao Duong on 16/8/2023.
//

import SwiftUI

struct CurrentExercisePreviewView: View {
    
    @ObservedObject var workout: Workout
    @State private var timerDuration: Int = 0
    
    var body: some View {
        HStack(alignment: .top) {
            VStack (alignment: .leading) {
                if timerDuration != 0 {
                    LinearTimer(duration: Double(timerDuration) + Double.random(in: 0..<1))
                }
               
                LabeledContent {
                    Picker("Timer Duration", selection: $timerDuration.animation()) {
                        ForEach(Array(stride(from: 0, to: 600, by: 5)), id: \.self) { duration in
                            Text(String(format: "%02d:%02d", duration / 60, duration % 60)).tag(duration)
                        }
                    }
                } label: {
                    Label("Timer Duration", systemImage: "timer.square")
                        .labelStyle(.iconOnly)
                }
                .fixedSize()
               
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(currentExercise?.uName.capitalized ?? "N/A")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Text(currentSet?.weight ?? 0.0, format: .number)
                            .font(.headline)
                        + Text(" KG")
                            .font(.caption)
                    }
                    Text("Set \(currentSetNumber ?? 0) of \(totalSets ?? 0)")
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
    
    var currentExercise: Exercise? {
        workout.currentExercise
    }
    var currentSet: ExerciseSet? {
        currentExercise?.currentSet
    }
    var currentSetNumber: Int? {
        guard let currentSet = currentSet else {
            return nil
        }
        guard let currentIndexNumber = currentExercise?.setsArray.firstIndex(of: currentSet) else {
            return nil
        }
        return currentIndexNumber + 1
    }
    var totalSets: Int? {
        currentExercise?.setsArray.count
    }
}

struct CurrentExercisePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentExercisePreviewView(workout: Workout.example)
    }
}
