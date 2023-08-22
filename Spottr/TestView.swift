//
//  TestView.swift
//  Spottr
//
//  Created by Hao Duong on 22/8/2023.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        DisclosureGroup("Hello") {
            EmptyView()
        }
        .disclosureGroupStyle(CustomDisclosureGroupStyle())
        .background(.red)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
