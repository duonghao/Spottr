//
//  LabelView.swift
//  Spottr
//
//  Created by Hao Duong on 17/8/2023.
//

import SwiftUI

struct LabelView<LabelView: View, MenuView: View>: View {
    
    let label: LabelView
    let menu: MenuView
    
    init(@ViewBuilder _ label: () -> LabelView, @ViewBuilder menu: () -> MenuView) {
        self.label = label()
        self.menu = menu()
    }
    
    var body: some View {
        ZStack {
            label
            HStack {
                Spacer()
                menu
            }
        }
    }
}

struct LabelView_Previews: PreviewProvider {
    static var previews: some View {
        LabelView {
            Text("Hi")
        } menu: {
            Text("Bye")
        }
    }
}
