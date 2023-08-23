//
//  HeaderView.swift
//  Spottr
//
//  Created by Hao Duong on 12/8/2023.
//

import SwiftUI

struct HeaderView<NavBarView: View>: View {
    
    var title: String
    var navBarTrailingContent: () -> NavBarView
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack {
                navBarTrailingContent()
            }
        }
        .font(.headline)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Hello", navBarTrailingContent: {Button("Add") {}})
    }
}
