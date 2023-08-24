//
//  WorkoutListView.swift
//  Spottr
//
//  Created by Hao Duong on 12/8/2023.
//

import SwiftUI

struct TemplatesListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: nil, animation: .spring()) var folders: FetchedResults<Folder>
    @State private var showingAddTemplateSheet: Bool = false
    @State private var showingAddFolderSheet: Bool = false
    @State private var dragging: Workout?
    @Binding var path: NavigationPath
    
    var body: some View {
        HeaderVStack(title: "Templates", spacing: 8) {
            ForEach(folders) { folder in
                FolderGroup(folder, dragging: $dragging, onMoveToFolder: move, onMoveToWorkouts: move)
                .navigationDestination(for: Workout.self) { workout in
                    WorkoutView(workout: workout) { oldValue, newValue in
                        guard let sourceFolder = folders.first(where: { $0.workoutsArray.contains(oldValue)}) else {
                            return
                        }
                        sourceFolder.removeFromWorkouts(oldValue)
                        sourceFolder.addToWorkouts(newValue)
                    }
                }
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
            AddTemplateSheet { newTemplate in
                path.append(newTemplate)
            }
        }
        .sheet(isPresented: $showingAddFolderSheet) {
            AddFolderSheet()
        }
    }
    
    // MARK: - Views
    
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
