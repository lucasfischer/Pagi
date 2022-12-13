//
//  TextEditorView.swift
//  TextEditorView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI
import NaturalLanguage

struct TextEditorView: UIViewControllerRepresentable {
    @Binding var text: String
    var font: String
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    @Binding var focusMode: Bool
    var focusType: FocusType
    @Binding var shouldHideToolbar: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = TextEditorController()
        if let view = viewController.view as? UITextView {
            view.delegate = context.coordinator
        }
        
        return viewController
    }
    
    func updateUIViewController(_ controller: UIViewController, context: Context) {
        guard let view = controller.view as? PagiTextView else { return }
        
        if view.text != text {
            view.text = text
            view.attributedText = NSAttributedString(string: text, attributes: view.defaultTypingAttributes)
        }
        
        if view.selectedFont != font {
            view.selectedFont = font
            view.font = UIFont(name: font, size: size)
        }
        if view.size != size {
            view.size = size
        }
        
        if focusMode != view.focusMode {
            context.coordinator.focusMode = focusMode
            view.focusMode = focusMode
            
            view.setContainerInsets()
            if focusMode {
                view.focusSelection(animated: false)
                view.highlightSelectedParagraph()
            } else {
                view.resetFocusMode()
            }
        }
        
        if focusType != view.focusType {
            context.coordinator.focusType = focusType
            view.focusType = focusType
            if focusMode {
                view.highlightSelectedParagraph()
            }
        }
        
        view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
        view.autocorrectionType = isSpellCheckingEnabled ? .yes : .no
    }
    
}

// MARK: - Coordinator
extension TextEditorView {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focusMode: focusMode, shouldHideToolbar: $shouldHideToolbar)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIScrollViewDelegate {
        var text: Binding<String>
        var focusMode: Bool
        var focusType: FocusType = .paragraph
        var shouldHideToolbar: Binding<Bool>
        
        private var lastVelocityYSign = 0
        
        init(text: Binding<String>, focusMode: Bool, shouldHideToolbar: Binding<Bool>) {
            self.text = text
            self.focusMode = focusMode
            self.shouldHideToolbar = shouldHideToolbar
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if (textView.markedTextRange != nil) {
                return
            }
            
            // TODO: debounce
            text.wrappedValue = textView.text
            shouldHideToolbar.wrappedValue = true
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let view = textView as? PagiTextView else { return }
            if focusMode {
                view.focusSelection(animated: true)
                view.highlightSelectedParagraph()
            }
        }
        
        // MARK: UIScrollView
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
            let currentVelocityYSign = Int(currentVelocityY).signum()
            if currentVelocityYSign != lastVelocityYSign &&
                currentVelocityYSign != 0 {
                lastVelocityYSign = currentVelocityYSign
            }
            if lastVelocityYSign < 0 {
                shouldHideToolbar.wrappedValue = true
            } else if lastVelocityYSign > 0 {
                shouldHideToolbar.wrappedValue = false
            }
        }
    }
    
}


extension TextEditorView {
    
    final class TextEditorController: UIViewController {
        private let textView = PagiTextView()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            textView.setContainerInsets()
            textView.typingAttributes = textView.defaultTypingAttributes
        }
        
        override func loadView() {
            self.view = textView
            let view = textView
            
            view.textColor = UIColor(.foreground)
            view.backgroundColor = UIColor(.background)
            view.isScrollEnabled = true
            view.isEditable = true
            view.isUserInteractionEnabled = true
            view.allowsEditingTextAttributes = false
            view.isPagingEnabled = false
            view.automaticallyAdjustsScrollIndicatorInsets = false
            view.contentInsetAdjustmentBehavior = .never
            
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            view.verticalScrollIndicatorInsets.bottom = scene?.windows.first?.safeAreaInsets.bottom ?? 0
            view.verticalScrollIndicatorInsets.top = scene?.windows.first?.safeAreaInsets.top ?? 0
            
            view.becomeFirstResponder()
        }
        
    }
    
}

extension TextEditorView {
    class PagiTextView: UITextView {
        var selectedFont: String = "iAWriterMonoV-Text"
        var size: Double = 18
        var focusMode: Bool = false
        var focusType: FocusType = .paragraph
        
        var defaultTypingAttributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineHeightMultiple = 1.3
            paragraphStyle.lineSpacing = 4
            
            return [
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                NSAttributedString.Key.font: UIFont(name: selectedFont, size: size)!,
                NSAttributedString.Key.foregroundColor: UIColor(.foreground)
            ]
        }
        
        func setContainerInsets() {
            let frameWidth = frame.size.width
            let frameHeight = frame.size.height
            let horizontalPadding = max(((frameWidth - 650) / 2), 16)
            let verticalPadding = focusMode ? frameHeight / 2 : 80
            let inset = UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )
            
            textContainerInset = focusMode ? inset : .zero
            contentInset = focusMode ? .zero : inset
        }
        
        private func setTemporaryForegroundColor(
            _ color: Color,
            forCharacterRange: NSRange? = nil
        ) {
            // Use full string range if none was provided
            let range = forCharacterRange ?? NSRange(text.startIndex..<text.endIndex, in: text)
            
            var attributes = defaultTypingAttributes
            attributes[.foregroundColor] = UIColor(color)
            textStorage.setAttributes(attributes, range: range)
        }
        
        func resetFocusMode() {
            setContainerInsets()
            setTemporaryForegroundColor(.foreground)
        }
        
        func highlightSelectedParagraph() {
            let textView = self
            let text = textView.text!
            let selectedRange = textView.selectedRange
            
            if focusType == .typeWriter {
                setTemporaryForegroundColor(.foreground)
                return
            } else {
                setTemporaryForegroundColor(.foregroundFaded)
            }
            
            var range = Range(selectedRange, in: text)!
            // Fix for last character in String
            if range.lowerBound == text.endIndex && range.lowerBound != text.startIndex {
                let lowerBound = text.index(range.lowerBound, offsetBy: -1)
                range = lowerBound..<range.upperBound
            }
            
            // Find range in current selection
            let tokenizer = NLTokenizer(unit: focusType == .paragraph ? .paragraph : .sentence)
            tokenizer.string = text
            let tokenRange = tokenizer.tokenRange(for: range)
            let paragraph = NSRange(tokenRange, in: text)
            setTemporaryForegroundColor(.foreground, forCharacterRange: paragraph)
        }
        
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
                focusType: .sentence,
                shouldHideToolbar: .constant(false)
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
