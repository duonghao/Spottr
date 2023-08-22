//
//  CustomDisclosureGroupStyle.swift
//  Spottr
//
//  Created by Hao Duong on 17/8/2023.
//

import SwiftUI
import Foundation

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    
    var padding: Double = 0
    var onDelete: (() -> Void)? = nil

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                HStack(alignment: .center, spacing: 0) {
                    configuration.label
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 1) { expand(configuration) }
                
                HStack {
                    Spacer()
                    Menu {
                        Button("Expand") { expand(configuration) }
                        if let onDelete = onDelete {
                            Button("Delete", role: .destructive, action: onDelete)
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .padding([.top, .bottom, .leading])
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(padding)

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
