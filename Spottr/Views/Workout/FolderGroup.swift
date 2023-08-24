//
//  Group.swift
//  Spottr
//
//  Created by Hao Duong on 24/8/2023.
//

import SwiftUI

struct FolderGroup: View {
    
    @ObservedObject var folder: Folder
    @Binding var dragging: Workout?
    var onMoveToFolder: (Workout, Folder) -> Void
    var onMoveToWorkouts: (Workout, Folder, Workout) -> Void

    init(_ folder: Folder, dragging: Binding<Workout?>, onMoveToFolder: @escaping (Workout, Folder) -> Void, onMoveToWorkouts: @escaping (Workout, Folder, Workout) -> Void) {
        self.folder = folder
        self._dragging = dragging
        self.onMoveToFolder = onMoveToFolder
        self.onMoveToWorkouts = onMoveToWorkouts
    }
    
    // MARK: - Views
    
    var body: some View {
            DisclosureGroup {
                workouts(from: folder)
            } label: {
                Text(folder.uName)
                    .font(.headline)
            }
            .disclosureGroupStyle(CustomDisclosureGroupStyle(onDelete: {}))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .stroke(.primary, lineWidth: 1)
            )
            .dropDestination(for: String.self) { _, _ in
                dragging = nil
                return false
            } isTargeted: { status in
                withAnimation(.spring()) {
                    if let dragging, status {
                        onMoveToFolder(dragging, folder)
                    }
                }
            }
    }
    
    private func workouts(from folder: Folder) -> some View {
        VStack {
            ForEach(folder.workoutsArray) { workout in
                WorkoutNavView(workout: workout) { workout in
                    folder.removeFromWorkouts(workout)
                }
                .draggable(workout.uid) {
                    dragPreview(workout: workout)
                }
                .dropDestination(for: String.self) { _, _ in
                    dragging = nil
                    return false
                } isTargeted: { status in
                    withAnimation(.spring()) {
                        if let dragging, status, dragging != workout {
                            onMoveToWorkouts(dragging, folder, workout)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func dragPreview(workout: Workout) -> some View {
        EmptyView()
            .frame(width: 1, height: 1)
            .onAppear {
                dragging = workout
            }
    }

}

struct FolderGroup_Previews: PreviewProvider {
    static var previews: some View {
        FolderGroup(Folder.example, dragging: .constant(nil)) { _, _ in
            
        } onMoveToWorkouts: { _, _, _ in
            
        }
    }
}
