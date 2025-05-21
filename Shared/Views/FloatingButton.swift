import SwiftUI

struct FloatingButton<Label: View>: View {
    @ViewBuilder var label: () -> Label
    var onPress: () -> Void = {}
    
    @State private var offset: CGPoint = CGPoint()
    @State private var isDragging = false
    @State private var contentSize: CGSize = .zero
    @AppStorage("") private var buttonPosition = Position.right
    
    init(id: String, onPress: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self._buttonPosition = AppStorage(wrappedValue: Position.right, id)
        self.onPress = onPress
        self.label = label
    }
    
    @GestureState private var isPressed = false
    
    func position(_ geometry: GeometryProxy) -> CGPoint {
        let x = buttonPosition == .right ? geometry.size.width - contentSize.width : contentSize.width
        let y = geometry.size.height - contentSize.height
        
        return CGPoint(
            x: x + offset.x,
            y: y + offset.y
        )
    }
    
    func drag(_ geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { v in
                self.isDragging = true
                offset = CGPoint(x: v.translation.width, y: v.translation.height)
            }
            .onEnded { v in
                self.isDragging = false
                
                if v.location.x >= geometry.size.width / 2 {
                    buttonPosition = .right
                } else {
                    buttonPosition = .left
                }
                
                offset = CGPoint()
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 30)
            .updating($isPressed) { currentState, gestureState, transaction in
                gestureState = currentState
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                onPress()
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            label()
                .onGeometryChange(
                    for: CGSize.self,
                    of: \.size,
                    action: { self.contentSize = $0 }
                )
                .scaleEffect((isDragging || isPressed) ? 1.5 : 1)
                .position(position(geometry))
                .gesture(
                    SimultaneousGesture(SimultaneousGesture(longPressGesture, drag(geometry)), tapGesture)
                )
                .animation(.bouncy, value: offset)
                .animation(.bouncy, value: isDragging)
                .animation(.bouncy, value: isPressed)
                .sensoryFeedback(.selection, trigger: isDragging)
                .sensoryFeedback(.selection, trigger: isPressed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension FloatingButton {
    
    enum Position: String {
        case left, right
    }
    
}

#Preview {
    FloatingButton(id: "preview") {
        print("onPress")
    } label: {
        Circle()
            .fill(.red)
            .frame(width: 44, height: 44)
    }
    .preferredColorScheme(.dark)
}
