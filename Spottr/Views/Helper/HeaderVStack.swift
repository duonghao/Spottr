//
//  HeaderVStack.swift
//  Spottr
//
//  Created by Hao Duong on 21/8/2023.
//

import SwiftUI

struct HeaderVStack<Content: View, NavContent: View>: View {
    
    let title: String
    let spacing: Double
    let content: () -> Content
    let navBarTrailingContent: () -> NavContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HeaderView(title: title) {
                navBarTrailingContent()
            }
            content()
        }
    }
}

struct HeaderVStack_Previews: PreviewProvider {
    static var previews: some View {
        HeaderVStack(title: "Title", spacing: 20) {
            ScrollView(.vertical) {
                VStack {
                    ForEach(0..<5, id: \.self) {_ in
                        Rectangle().fill(.red).frame(width: 200, height: 200)
                    }
                }
            }
        } navBarTrailingContent: {
            Button("plus") {}
        }

    }
}
