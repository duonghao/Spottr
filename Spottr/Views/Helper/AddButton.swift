//
//  AddButton.swift
//  Spottr
//
//  Created by Hao Duong on 16/8/2023.
//

import SwiftUI

struct AddButton: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Label(title, systemImage: "plus")
                .labelStyle(.iconOnly)
        }
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(title: "Add Workout", action: {})
    }
}
