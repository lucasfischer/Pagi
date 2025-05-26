import SwiftUI

public struct FloatingPlusButton: View {
    var color: Color = .green
    var onPress: () -> Void = {}
    
    public init(color: Color = .green, onPress: @escaping () -> Void = {}) {
        self.color = color
        self.onPress = onPress
    }
    
    private let circleSize: Double = 48
    
    public var body: some View {
        FloatingButton(id: "floating-plus-button", onPress: onPress) {
            Circle()
                .fill(color)
                .frame(width: circleSize, height: circleSize)
                .shadow(radius: 3)
                .overlay {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                }
            
        }
    }
}

#Preview {
    FloatingPlusButton() {
        print("on press")
    }
    .preferredColorScheme(.dark)
}
