import SwiftUI

public struct ViewAlertModifier<A, M, T>: ViewModifier where A : View, M : View {
    public var titleKey: LocalizedStringKey
    public var data: Binding<T?>
    public var actions: (T) -> A
    public var message: (T) -> M
    
    public func body(content: Content) -> some View {
        let isPresented = Binding<Bool>(get: {
            data.wrappedValue != nil
        }, set: {
            if !$0 {
                data.wrappedValue = nil
            }
        })
        
        content
            .alert(titleKey, isPresented: isPresented, presenting: data.wrappedValue, actions: actions, message: message)
    }
    
}

public extension View {
    
    /// Presents an alert with a message using the given data to produce the alert’s content and a text view for a title.
    func alert<A, M, T>(
        _ titleKey: LocalizedStringKey,
        presenting data: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View where A: View, M: View {
        self.modifier(
            ViewAlertModifier(
                titleKey: titleKey,
                data: data,
                actions: actions,
                message: message
            )
        )
    }
    
}


public extension View {
    
    // Presents an alert with a message using the given error to produce the alert’s content and a text view for a title.
    func errorAlert<E>(error: Binding<E?>) -> some View where E: Error {
        self.modifier(
            ViewAlertModifier(
                titleKey: "Error",
                data: error,
                actions: { _ in
                    Button("OK") {
                        error.wrappedValue = nil
                    }
                },
                message: { error in
                    Text(error.localizedDescription)
                }
            )
        )
    }
    
}
