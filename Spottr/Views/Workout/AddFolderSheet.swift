//
//  AddFolderSheet.swift
//  Spottr
//
//  Created by Hao Duong on 22/8/2023.
//

import SwiftUI

struct AddFolderSheet: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Add Folder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Dimiss") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save", action: save).disabled(name.isEmpty) }
            }
        }
    }
    
    func save() -> Void {
        let newFolder = Folder(context: moc)
        newFolder.id = UUID()
        newFolder.name = name
        
        PersistenceController.shared.save()
        
        dismiss()
    }
}

struct AddFolderSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddFolderSheet()
    }
}
