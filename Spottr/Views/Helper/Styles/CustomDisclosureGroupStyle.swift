//
//  CustomDisclosureGroupStyle.swift
//  Spottr
//
//  Created by Hao Duong on 17/8/2023.
//

import SwiftUI
import Foundation

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    
    var onDelete: () -> Void

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                configuration.label
                Spacer()
                Menu {
                    Button("Expand") { expand(configuration) }
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Label("Options", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .contentShape(Circle())
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { expand(configuration) }
            if configuration.isExpanded {
                configuration.content
                    .disclosureGroupStyle(self)
            }
        }
    }
    
    private func expand(_ configuration: Configuration) {
        withAnimation {
            configuration.isExpanded.toggle()
        }
    }
}
