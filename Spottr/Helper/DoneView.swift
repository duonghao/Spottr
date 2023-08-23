//
//  DoneView.swift
//  Spottr
//
//  Created by Hao Duong on 5/8/2023.
//

import SwiftUI

struct DoneView: View {
    
    @Environment(\.managedObjectContext) var moc
    var workout: Workout

    init(workout: Workout) {
        self.workout = workout
        self.setEnd(workout: workout)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                Text(workout.uName)
                Text("Completed")
            }
            .font(.largeTitle)
            .bold()
            
            HStack() {
                Spacer()
                VStack {
                    Text("Duration")
                        .font(.caption)
                    Text(workout.duration)
                }
                Spacer()
                VStack {
                    Text("Volume")
                        .font(.caption)
                    Text(workout.volume, format: .number) + Text("KG")
                }
                Spacer()
                VStack {
                    Text("Sets")
                        .font(.caption)
                    Text(workout.setsDone, format: .number)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    func setEnd(workout: Workout) {
        if workout.endDate == nil {
            workout.endDate = Date.now
        }
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
    
}

struct DoneView_Previews: PreviewProvider {
    
    static var previews: some View {
        DoneView(workout: Workout.example)
    }
}
