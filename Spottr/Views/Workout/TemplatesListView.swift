//
//  WorkoutListView.swift
//  Spottr
//
//  Created by Hao Duong on 12/8/2023.
//

import SwiftUI

struct TemplatesListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: nil) var folders: FetchedResults<Folder>
    @State private var showingAddTemplateSheet: Bool = false
    @State private var showingAddFolderSheet: Bool = false
    @State private var dragging: Workout?
    @Binding var path: NavigationPath
    
    var body: some View {
        HeaderVStack(title: "Templates", spacing: 8) {
            ForEach(folders) { folder in
                group(folder)
            }
        } navBarTrailingContent: {
            Menu {
                templateAdder
                folderAdder
            } label: {
                Label("Add", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }
        }
        .sheet(isPresented: $showingAddTemplateSheet) {
            AddTemplateSheet(onSave: { _ in})
        }
        .sheet(isPresented: $showingAddFolderSheet) {
            AddFolderSheet()
        }
    }
    
    // MARK: - Views
    
    private func workouts(from folder: Folder) -> some View {
        VStack {
            ForEach(folder.workoutsArray) { workout in
                WorkoutNavView(workout: workout)
                    .draggable(workout.uid) {
                        dragPreview(workout: workout)
                    }
                    .dropDestination(for: String.self) { _, _ in
                        dragging = nil
                        return false
                    } isTargeted: { status in
                        withAnimation(.spring()) {
                            if let dragging, status, dragging != workout {
                                move(dragging, to: folder, at: workout)
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
    
    private var folderAdder: some View {
        Button {
            showingAddFolderSheet = true
        } label: {
            Label("Folder", systemImage: "folder")
        }
    }
    
    private var templateAdder: some View {
        Button {
            showingAddTemplateSheet = true
        } label: {
            Label("Template", systemImage: "list.dash.header.rectangle")
        }
    }
    
    private func group(_ folder: Folder) -> some View {
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
                    move(dragging, to: folder)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func move(_ workout: Workout, to destinationFolder: Folder, at destinationWorkout: Workout) {
        guard
            let sourceFolder = folders.filter({ $0.workoutsArray.contains(workout) }).first,
            let sourceIndex = sourceFolder.workoutsArray.firstIndex(where: { $0 == workout }),
            let destinationIndex = destinationFolder.workoutsArray.firstIndex(where: { $0 == destinationWorkout })
        else {
            return
        }
        
        sourceFolder.removeFromWorkouts(at: sourceIndex)
        destinationFolder.insertIntoWorkouts(workout, at: destinationIndex)
        
        save()
    }
    
    private func move(_ workout: Workout, to destinationFolder: Folder) {
        guard
            let sourceFolder = folders.filter({ $0.workoutsArray.contains(workout) }).first,
            let sourceIndex = sourceFolder.workoutsArray.firstIndex(where: { $0 == workout })
        else {
            return
        }
        
        sourceFolder.removeFromWorkouts(at: sourceIndex)
        destinationFolder.insertIntoWorkouts(workout, at: 0)
        
        save()
    }
    
    private func deleteTemplate(template: Workout) {
        moc.delete(template)
        save()
    }
    
    private func save() {
        PersistenceController.shared.save()
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var path: NavigationPath = NavigationPath()
    
    static var previews: some View {
        TemplatesListView(path: .constant(path))
    }
}
