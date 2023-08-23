//
//  GeometryReaderView.swift
//  Spottr
//
//  Created by Hao Duong on 16/8/2023.
//

import SwiftUI

struct GeometryReaderView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            self.content
                    .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
