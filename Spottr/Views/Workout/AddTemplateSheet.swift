//
//  AddTemplateSheet.swift
//  Spottr
//
//  Created by Hao Duong on 22/8/2023.
//

import SwiftUI

struct AddTemplateSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var folders: FetchedResults<Folder>
    
    @State private var name: String
    @State private var selectedFolder: Folder
    
    let onSave: (Workout) -> Void
    
    init(name: String = "", onSave: @escaping (Workout) -> Void) {
        _name = State(initialValue: name)
        _selectedFolder = State(initialValue: Folder.defaultFolder)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text:$name)
                }
                
                Section("Folder") {
                    ForEach(folders) { folder in
                        label(folder)
                            .onTapGesture {
                                updateSelected(folder)
                            }
                    }
                }
            }
            .navigationTitle("Add Template")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Dismiss") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save", action: save).disabled(name.isEmpty) }
            }
        }
    }
    
    func updateSelected(_ folder: Folder) {
        selectedFolder = folder
    }
    
    func save() {
        let newTemplate = Workout(context: moc)
        newTemplate.id = UUID()
        newTemplate.name = name
        newTemplate.isTemplate = true
        
        selectedFolder.addToWorkouts(newTemplate)
        
        PersistenceController.shared.save()
    
        dismiss()
        
        onSave(newTemplate)
    }
    
    func label(_ folder: Folder) -> some View {
        HStack {
            Text(folder.uName)
            Spacer()
            if (folder == selectedFolder) {
                Image(systemName: "checkmark")
            }
        }
    }
}

struct AddTemplateSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTemplateSheet(onSave: { _ in })
    }
}
