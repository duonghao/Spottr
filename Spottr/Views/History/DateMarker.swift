//
//  DateMarker.swift
//  Spottr
//
//  Created by Hao Duong on 8/8/2023.
//

import SwiftUI

struct DateMarker: View {
    let date: Date
    let numberOfDots: Int
    let fillColor: Color
    let emptyColor: Color
    
    var body: some View {
        Text("30")
            .hidden()
            .padding(8)
            .background(numberOfDots == 0 ? emptyColor : fillColor)
            .clipShape(Circle())
            .padding(.vertical, 4)
            .overlay {
                Text(String(Calendar.current.component(.day, from: date)))
                HStack {
                    ForEach(0..<numberOfDots, id: \.self) { _ in
                        Circle().frame(width: 6)
                    }
                }
                .offset(x: 0, y: 24)
            }
    }
}

struct DateMarker_Previews: PreviewProvider {
    static var previews: some View {
        DateMarker(date: Date.now, numberOfDots: 2, fillColor: .yellow, emptyColor: .clear)
    }
}
