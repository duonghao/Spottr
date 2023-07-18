//
//  NextWorkoutPreviewView.swift
//  Spottr
//
//  Created by Hao Duong on 12/8/2023.
//

import SwiftUI

struct NextWorkoutPreviewView: View {
    
    @ObservedObject var program: Program
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text("Next Workout")
                    .font(.subheadline)
                    .padding(.bottom, 4)
                Text(program.currentWorkout?.uName ?? "NA")
                    .font(.headline)
                Text(program.currentWorkout?.uniqueExerciseGroups.map({ $0.capitalized }).joined(separator: ", ") ?? "NA")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Start")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
}

struct NextWorkoutPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            NextWorkoutPreviewView(program: Program.example)
        }
    }
}
