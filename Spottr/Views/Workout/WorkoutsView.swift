//
//  WorkoutTabView.swift
//  Spottr
//
//  Created by Hao Duong on 1/8/2023.
//

import OrderedCollections
import SwiftUI

struct WorkoutsView: View {
    
    @FetchRequest(sortDescriptors: [], predicate: nil) var programs: FetchedResults<Folder>
    @State private var path = NavigationPath()
    @State private var showingAddWorkout = false
    
    // MARK: - Views
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    startEmptyWorkout
                    TemplatesListView(path: $path)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutSheet() { workout in
                path.append(workout)
            }
        }
        .navigationDestination(for: Workout.self) { workout in
            WorkoutView(workout: workout) { _, _ in
                
            }
        }
    }
    
    var startEmptyWorkout: some View {
        Button {
            showingAddWorkout = true
        } label: {
            Label("Start Empty Workout", systemImage: "flame")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        }
    }
    
}

struct WorkoutsView_Preview: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
