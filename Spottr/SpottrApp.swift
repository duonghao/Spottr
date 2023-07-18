//
//  SpottrApp.swift
//  Spottr
//
//  Created by Hao Duong on 18/7/2023.
//

import SwiftUI

@main
struct SpottrApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
