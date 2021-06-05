//
//  ProgressBar.swift
//  Pagi
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

public struct ProgressBar: View {
    var percent: Float
    var color: Color
    
    public init(percent: Float, color: Color = Color.primary) {
        self.percent = percent
        self.color = color
    }
    
    func getX(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * CGFloat(percent)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Line(start: CGPoint(x: 0, y: 2.5), end: CGPoint(x: getX(geometry), y: 2.5))
                .stroke(color, lineWidth: 5)
                .animation(.default)
        }
        .frame(height: 5)
    }
}

private struct Line: Shape {
    var start, end: CGPoint
    
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: start)
            p.addLine(to: end)
        }
    }
}



struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(percent: 0.5)
    }
}
