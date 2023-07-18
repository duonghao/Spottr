//
//  LinearTimer.swift
//  Spottr
//
//  Created by Hao Duong on 14/8/2023.
//

import SwiftUI

struct LinearTimer: View {
    
    static var timerInterval: Double = 1 / 60
    private var fracRemaining: Double {
        abs(durationRemaining / duration)
    }
    @State private var durationRemaining: Double
    @State private var timer = Timer.publish(every: Self.timerInterval, on: .main, in: .common).autoconnect()
    var duration: Double
    
    init(duration: Double) {
        self.duration = duration
        _durationRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geo in
                Rectangle()
                    .frame(width: geo.size.width)
                    .foregroundColor(.yellow.opacity(0.25))
                
                Rectangle()
                    .frame(width: CGFloat(fracRemaining) * geo.size.width)
                    .foregroundColor(.yellow.opacity(0.75))
            }
            .frame(maxHeight: 28)
        }
        .onReceive(timer) { _ in
            if durationRemaining > 0 {
                durationRemaining -= Self.timerInterval
            }
        }
        .onChange(of: duration) { newValue in
            durationRemaining = newValue
        }
    }
}

struct LinearTimer_Previews: PreviewProvider {
    static var previews: some View {
        LinearTimer(duration: 60)
    }
}
