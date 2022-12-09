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
    @Binding var focusMode: Bool
    var focusType: FocusType
    
    var body: some View {
        GeometryReader { geometry in
            MultilineTextView(
                text: $text,
                font: font,
                size: size,
                isSpellCheckingEnabled: isSpellCheckingEnabled,
                height: geometry.size.height
            )
            .ignoresSafeArea(.all, edges: [.bottom])
        }
    }
    
    struct MultilineTextView: UIViewRepresentable {
        @Binding var text: String
        var font: String
        var size: CGFloat
        var isSpellCheckingEnabled: Bool = false
        var height: Double
        
        func makeUIView(context: Context) -> UITextView {
            let view = PagiTextView()
            
            view.delegate = context.coordinator
            
            view.font = UIFont(name: font, size: size)
            view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
            view.autocorrectionType =  isSpellCheckingEnabled ? .yes : .no
            view.textColor = UIColor(.foreground)
            view.isScrollEnabled = true
            view.isEditable = true
            view.isUserInteractionEnabled = true
            
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            // Style
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineHeightMultiple = 1.3
            paragraphStyle.lineSpacing = 4
            
            let attributes = [
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                NSAttributedString.Key.font: UIFont(name: font, size: size),
                NSAttributedString.Key.foregroundColor: UIColor(.foreground)
            ]
            view.typingAttributes = attributes as [NSAttributedString.Key : Any]
            
            view.text = text
            
            view.becomeFirstResponder()
            
            return view
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            if uiView.text != text {
                uiView.text = text
            }
            
            context.coordinator.height = self.height
            
            // TODO: Call when `viewWillLayout`
            let frameWidth = uiView.frame.size.width
            let horizontalPadding = max(((frameWidth - 650) / 2), 16)
            uiView.textContainerInset = UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: horizontalPadding)
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, height: height)
        }
        
        class Coordinator: NSObject, UITextViewDelegate, UIScrollViewDelegate {
            var text: Binding<String>
            var height: Double
            
            init(text: Binding<String>, height: Double) {
                self.text = text
                self.height = height
            }
            
            func textViewDidChange(_ textView: UITextView) {
                if (textView.markedTextRange != nil) {
                    return
                }
                self.text.wrappedValue = textView.text
            }
            
            func textViewDidChangeSelection(_ textView: UITextView) {
                guard let view = textView as? PagiTextView else { return }
                view.focusSelection(height: height, animated: true)
            }
        }
    }
}

extension TextEditorView {
    class PagiTextView: UITextView {
        
        func focusSelection(height: Double, animated: Bool = false) {
            let rect = layoutManager.boundingRect(forGlyphRange: selectedRange, in: textContainer)
            let y = rect.origin.y - (rect.height + height / 3)
            DispatchQueue.main.async { // Without this tapping has no effect.
                self.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
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
                font: iAFont.quattro.fileName,
                size: 18,
                isSpellCheckingEnabled: false,
                focusMode: .constant(false),
                focusType: .sentence
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
