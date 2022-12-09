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
        MultilineTextView(
            text: $text,
            font: font,
            size: size,
            isSpellCheckingEnabled: isSpellCheckingEnabled
        )
    }
    
    struct MultilineTextView: UIViewControllerRepresentable {
        @Binding var text: String
        var font: String
        var size: CGFloat
        var isSpellCheckingEnabled: Bool = false
        
        var typingAttributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineHeightMultiple = 1.3
            paragraphStyle.lineSpacing = 4
            
            return [
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                NSAttributedString.Key.font: UIFont(name: font, size: size)!,
                NSAttributedString.Key.foregroundColor: UIColor(.foreground)
            ]
        }
        
        func makeUIViewController(context: Context) -> UIViewController {
            let viewController = TextEditorController()
            if let view = viewController.view as? UITextView {
                view.delegate = context.coordinator
            }
            
            return viewController
        }
        
        func updateUIViewController(_ controller: UIViewController, context: Context) {
            guard let view = controller.view as? UITextView else { return }
            
            if view.text != text {
                view.text = text
                view.attributedText = NSAttributedString(string: text, attributes: typingAttributes)
            }
            
            view.typingAttributes = typingAttributes
            view.font = UIFont(name: font, size: size)
            view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
            view.autocorrectionType = isSpellCheckingEnabled ? .yes : .no
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }
        
        class Coordinator: NSObject, UITextViewDelegate, UIScrollViewDelegate {
            var text: Binding<String>
            
            init(text: Binding<String>) {
                self.text = text
            }
            
            func textViewDidChange(_ textView: UITextView) {
                if (textView.markedTextRange != nil) {
                    return
                }
                self.text.wrappedValue = textView.text
            }
            
            func textViewDidChangeSelection(_ textView: UITextView) {
                guard let view = textView as? PagiTextView else { return }
                view.focusSelection(animated: true)
            }
        }
    }
}

extension TextEditorView {
    final class TextEditorController: UIViewController {
        private let textView = PagiTextView()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let view = self.view as? UITextView {
                let frameWidth = view.frame.size.width
                let frameHeight = view.frame.size.height
                let horizontalPadding = max(((frameWidth - 650) / 2), 16)
                let verticalPadding = frameHeight / 2
                view.textContainerInset = UIEdgeInsets(
                    top: verticalPadding,
                    left: horizontalPadding,
                    bottom: verticalPadding,
                    right: horizontalPadding
                )
            }
        }
        
        override func loadView() {
            self.view = textView
            let view = textView
            
            view.textColor = UIColor(.foreground)
            view.isScrollEnabled = true
            view.isEditable = true
            view.isUserInteractionEnabled = true
            view.allowsEditingTextAttributes = false
            
            view.becomeFirstResponder()
        }
    }
}

extension TextEditorView {
    class PagiTextView: UITextView {
        
        
        func focusSelection(animated: Bool = false) {
            self.layoutIfNeeded()
            
            let rect = layoutManager.boundingRect(forGlyphRange: selectedRange, in: textContainer)
            let y = (rect.origin.y + rect.height).rounded()
            
            if self.contentOffset.y != y {
                UIView.animate(withDuration: 0.15) {
                    self.setContentOffset(CGPoint(x: 0, y: y), animated: false)
                }
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
