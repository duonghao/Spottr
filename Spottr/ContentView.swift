//
//  ContentView.swift
//  Spottr
//
//  Created by Hao Duong on 18/7/2023.
//

import SwiftUI

enum Tab: String, Hashable, CaseIterable {
    case workouts = "Workouts", history = "History", progress = "Progress"
}

struct ContentView: View {
    
    @State private var selectedTab: Tab = .workouts
    
    var body: some View {
        TabView(selection: $selectedTab) {
                NavigationStack {
                    WorkoutsView()
                        .navigationTitle(Tab.workouts.rawValue)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label(Tab.workouts.rawValue, systemImage: "dumbbell")
                }
                .tag(Tab.workouts)
         
                NavigationStack {
                    HistoryTabView()
                        .navigationTitle(Tab.history.rawValue)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: "calendar")
                }
                .tag(Tab.history)
                
                NavigationStack {
                    ProgressTabView()
                        .navigationTitle(Tab.progress.rawValue)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label(Tab.progress.rawValue, systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
