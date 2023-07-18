//
//  WorkoutListView.swift
//  Spottr
//
//  Created by Hao Duong on 12/8/2023.
//

import SwiftUI

struct TemplatesListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "isTemplate == YES")) var workouts: FetchedResults<Workout>
    @State private var name: String = ""
    @State private var showingAddTemplateAlert: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            HeaderView(title: "Templates") {
                AddButton(title: "Add Template", action: { showingAddTemplateAlert = true })
            }
            
            ForEach(workouts) { workout in
                WorkoutNavView(workout: workout)
            }
        }
        .alert("Enter a template name", isPresented: $showingAddTemplateAlert) {
            TextField("name", text: $name)
            Button("OK", action: addTemplate)
        }
    }

    func addTemplate() {
        let newTemplate = Workout(context: moc)
        newTemplate.id = UUID()
        newTemplate.name = name
        newTemplate.isTemplate = true
        
        // Reset
        name = ""
        
        path.append(newTemplate)
        
        save()
    }
    
    func deleteTemplate(template: Workout) {
        moc.delete(template)
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var path: NavigationPath = NavigationPath()
    
    static var previews: some View {
        TemplatesListView(path: .constant(path))
    }
}
