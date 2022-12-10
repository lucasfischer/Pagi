//
//  TextEditorView.swift
//  TextEditorView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI


struct TextEditorView: UIViewControllerRepresentable {
    @Binding var text: String
    var font: String
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    @Binding var focusMode: Bool
    var focusType: FocusType
    
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
        guard let vc = controller as? TextEditorController,
              let view = controller.view as? PagiTextView
        else { return }
        
        if view.text != text {
            view.text = text
            view.attributedText = NSAttributedString(string: text, attributes: typingAttributes)
        }
        
        view.typingAttributes = typingAttributes
        view.font = UIFont(name: font, size: size)
        view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
        view.autocorrectionType = isSpellCheckingEnabled ? .yes : .no
        
        if focusMode != vc.focusMode {
            vc.focusMode = focusMode
            vc.setContainerInsets()
            if focusMode {
                view.focusSelection(animated: false)
            }
        }
        context.coordinator.focusMode = focusMode
        vc.focusMode = focusMode
        vc.setContainerInsets()
    }
    
}

// MARK: - Coordinator
extension TextEditorView {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focusMode: focusMode)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIScrollViewDelegate {
        var text: Binding<String>
        var focusMode: Bool
        
        init(text: Binding<String>, focusMode: Bool) {
            self.text = text
            self.focusMode = focusMode
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if (textView.markedTextRange != nil) {
                return
            }
            self.text.wrappedValue = textView.text
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let view = textView as? PagiTextView else { return }
            if focusMode {
                view.focusSelection(animated: true)
            }
        }
    }
    
}


extension TextEditorView {
    
    final class TextEditorController: UIViewController {
        private let textView = PagiTextView()
        
        var focusMode: Bool = false
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            setContainerInsets()
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
        
        func setContainerInsets() {
            if let view = self.view as? UITextView {
                let frameWidth = view.frame.size.width
                let frameHeight = view.frame.size.height
                let horizontalPadding = max(((frameWidth - 650) / 2), 16)
                let verticalPadding = focusMode ? frameHeight / 2 : 32
                view.textContainerInset = UIEdgeInsets(
                    top: verticalPadding,
                    left: horizontalPadding,
                    bottom: verticalPadding,
                    right: horizontalPadding
                )
            }
        }
    }
    
}

extension TextEditorView {
    class PagiTextView: UITextView {
        
        func focusSelection(animated: Bool = false) {
            // TODO: re-write this without hacks
            self.layoutIfNeeded()
            
            let isCursorAtEndOfDocument = selectedTextRange?.end == endOfDocument // Is Cursor at the end of the document?
            
            let rect = self.layoutManager.boundingRect(forGlyphRange: self.selectedRange, in: self.textContainer)
            let y = (rect.origin.y + (isCursorAtEndOfDocument ? rect.height : 0)).rounded()
            
            let differenceIsTooBig = abs(self.contentOffset.y - y) >= rect.height
            if differenceIsTooBig {
                UIView.animate(withDuration: animated ?  0.15 : 0) {
                    self.contentOffset.y = y
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
