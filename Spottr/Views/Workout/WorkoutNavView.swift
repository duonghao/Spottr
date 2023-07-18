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
        LabelView {
            NavigationLink(value: workout) {
                HStack {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(workout.uName)
                                .font(.headline)
                            Text(exerciseGroups.map({$0.capitalized}).joined(separator:", "))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if let endDate = workout.endDate {
                            Text(endDate.formatted(date: .abbreviated, time: .omitted))
                                .padding()
                                .background(.thickMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                        }
                        Label("Options", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .padding()
                            .hidden()
                    }
                }
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            }
            .navigationDestination(for: Workout.self) { workout in
                WorkoutView(workout: workout)
            }
            .buttonStyle(.plain)
        } menu: {
            Menu {
                Button("Delete", role: .destructive) {
                    deleteWorkout()
                }
            } label: {
                Label("Options", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .padding()
                    .contentShape(Circle())
            }
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
