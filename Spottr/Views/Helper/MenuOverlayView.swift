//
//  LabelView.swift
//  Spottr
//
//  Created by Hao Duong on 17/8/2023.
//

import SwiftUI

struct MenuOverlayView<Content: View, Menu: View>: View {
    
    let content: Content
    let menu: Menu
    
    init(@ViewBuilder _ content: () -> Content, @ViewBuilder menu: () -> Menu) {
        self.content = content()
        self.menu = menu()
    }
    
    var body: some View {
        ZStack {
            content
            HStack {
                Spacer()
                menu
            }
        }
    }
}

struct LabelView_Previews: PreviewProvider {
    static var previews: some View {
        MenuOverlayView {
            Text("Hi")
        } menu: {
            Text("Bye")
        }
    }
}
