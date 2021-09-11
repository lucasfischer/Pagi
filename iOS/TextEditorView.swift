//
//  TextEditorView.swift
//  TextEditorView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var text: String
    var font: String
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    
    @State private var dynamicHeight: CGFloat = 40
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder Hack
            if text.isEmpty {
                TextEditor(text: .constant("Type something..."))
                    .font(.custom(font, size: size))
                    .foregroundColor(.foreground)
                    .opacity(text.isEmpty ? 0.5 : 0)
                    .disabled(true)
            }
            MultilineTextView(
                text: $text,
                calculatedHeight: $dynamicHeight,
                font: font,
                size: size,
                isSpellCheckingEnabled: isSpellCheckingEnabled
            )
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        }
    }
    
    struct MultilineTextView: UIViewRepresentable {
        @Binding var text: String
        @Binding var calculatedHeight: CGFloat
        var font: String
        var size: CGFloat
        var isSpellCheckingEnabled: Bool = false
        
        func makeUIView(context: Context) -> UITextView {
            let view = UITextView()
            
            view.delegate = context.coordinator
            
            view.font = UIFont(name: font, size: size)
            view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
            view.textColor = UIColor(.foreground)
            view.isScrollEnabled = false
            view.isEditable = true
            view.isUserInteractionEnabled = true
            
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            // Style
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            let attributes = [
                NSAttributedString.Key.paragraphStyle : style,
                NSAttributedString.Key.font: UIFont(name: font, size: size)
            ]
            view.typingAttributes = attributes
            
            view.text = text
            
            return view
        }
        
        fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
            let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            if result.wrappedValue != newSize.height {
                DispatchQueue.main.async {
                    result.wrappedValue = newSize.height // !! must be called asynchronously
                }
            }
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            let selectedRange = uiView.selectedRange
            uiView.text = text
            uiView.selectedRange = selectedRange
            
            MultilineTextView.recalculateHeight(view: uiView, result: $calculatedHeight)
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, calculatedHeight: $calculatedHeight)
        }
        
        class Coordinator: NSObject, UITextViewDelegate {
            var text: Binding<String>
            var calculatedHeight: Binding<CGFloat>
            
            init(text: Binding<String>, calculatedHeight: Binding<CGFloat>) {
                self.text = text
                self.calculatedHeight = calculatedHeight
            }
            
            func textViewDidChange(_ textView: UITextView) {
                if (textView.markedTextRange != nil) {
                    return
                }
                self.text.wrappedValue = textView.text
                MultilineTextView.recalculateHeight(view: textView, result: calculatedHeight)
            }
        }
    }
}

struct TextEditorView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var text = "Test text"
        
        var body: some View {
            TextEditorView(
                text: $text,
                font: "iAWriterQuattroV-Text",
                size: 18,
                isSpellCheckingEnabled: false
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
