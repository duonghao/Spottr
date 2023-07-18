//
//  WorkoutTabView.swift
//  Spottr
//
//  Created by Hao Duong on 1/8/2023.
//

import OrderedCollections
import SwiftUI

struct WorkoutsView: View {
    
    @FetchRequest(sortDescriptors: [], predicate: nil) var programs: FetchedResults<Program>
    @State private var path = NavigationPath()
   
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TemplatesListView(path: $path)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct WorkoutsView_Preview: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
