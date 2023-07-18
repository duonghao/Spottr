//
//  CustomDisclosureGroupStyle.swift
//  Spottr
//
//  Created by Hao Duong on 17/8/2023.
//

import SwiftUI
import Foundation

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                configuration.label
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            }
            if configuration.isExpanded {
                configuration.content
                    .disclosureGroupStyle(self)
            }
        }
    }
}
