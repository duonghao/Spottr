//
//  WorkoutRow.swift
//  Spottr
//
//  Created by Hao Duong on 18/7/2023.
//

import SwiftUI

struct WorkoutNavView: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var workout: Workout
    
    var body: some View {
        MenuOverlayView {
            NavigationLink(value: workout, label: workoutLinkLabel)
            .navigationDestination(for: Workout.self) { workout in
                WorkoutView(workout: workout)
            }
            .buttonStyle(.plain)
        } menu: {
            Menu {
                Button("Delete", role: .destructive, action: deleteWorkout)
            } label: {
                optionsLabel.contentShape(Circle())
            }
        }
    }
    
    func workoutLinkLabel() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                workoutSummary
            }
            Spacer()
            endDate
            optionsLabel.hidden()
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
    
    @ViewBuilder
    var workoutSummary: some View {
        Text(workout.uName)
            .font(.headline)
            .lineLimit(1, reservesSpace: true)
        Text(exerciseGroups.map({$0.capitalized}).joined(separator:", "))
            .foregroundColor(.secondary)
            .lineLimit(2, reservesSpace: true)
    }
    
    var optionsLabel: some View {
        Label("Options", systemImage: "ellipsis")
            .labelStyle(.iconOnly)
            .padding()
    }
    
    @ViewBuilder
    var endDate: some View {
        if let endDate = workout.endDate {
            Text(endDate.formatted(date: .abbreviated, time: .omitted))
                .padding()
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        }
    }
    
    var exerciseGroups: [String] {
        let groups: [String] = workout.exercisesArray.map({$0.exerciseType.group})
        return Array(Set(groups))
    }
    
    func deleteWorkout() {
        moc.delete(workout)
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct WorkoutNavView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutNavView(workout: Workout.example)
    }
}
