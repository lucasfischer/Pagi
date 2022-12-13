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
        @Binding var text: String
        var focusMode: Bool
        @Binding var shouldHideToolbar: Bool
        
        private var lastVelocityYSign = 0
        
        init(text: Binding<String>, focusMode: Bool, shouldHideToolbar: Binding<Bool>) {
            self._text = text
            self.focusMode = focusMode
            self._shouldHideToolbar = shouldHideToolbar
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if (textView.markedTextRange != nil) {
                return
            }
            
            // TODO: debounce
            text = textView.text
            shouldHideToolbar = true
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
            if currentVelocityYSign != lastVelocityYSign {
                lastVelocityYSign = currentVelocityYSign
            }
            if lastVelocityYSign < 0 {
                shouldHideToolbar = true
                UIView.animate(withDuration: 0.3) {
                    scrollView.resetScrollIndicators()
                }
            } else if lastVelocityYSign > 0 {
                shouldHideToolbar = false
                UIView.animate(withDuration: 0.3) {
                    scrollView.padScrollIndicators()
                }
            }
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            guard let view = scrollView as? PagiTextView else { return }
            view.resetHighlight()
        }
    }
    
}


extension TextEditorView {
    
    final class TextEditorController: UIViewController {
        private let textView = PagiTextView()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            textView.setContainerInsets()
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
            
            view.resetScrollIndicators()
            
            view.becomeFirstResponder()
        }
        
    }
    
}

extension TextEditorView {
    enum HighlightState: String {
        case full
        case partial
    }
    
    class PagiTextView: UITextView {
        var selectedFont: String = "iAWriterMonoV-Text"
        var size: Double = 18
        var focusMode: Bool = false
        var focusType: FocusType = .paragraph
        var highlightState: HighlightState = .full
        
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
            let horizontalPadding = max((frameWidth - 650) / 2, 16)
            let inset = UIEdgeInsets(
                top: focusMode ? frameHeight / 2 : 120,
                left: horizontalPadding,
                bottom: focusMode ? frameHeight / 2 : 80,
                right: horizontalPadding
            )
            
            textContainerInset = focusMode ? inset : .zero
            contentInset = focusMode ? .zero : inset
        }
        
        private func highlightRange(_ range: NSRange) {
            highlightState = .partial
            textColor = UIColor(.foregroundFaded)
            var attributes = defaultTypingAttributes
            attributes[.foregroundColor] = UIColor(.foreground)
            textStorage.setAttributes(attributes, range: range)
        }
        
        func resetFocusMode() {
            setContainerInsets()
            resetHighlight()
        }
        
        func resetHighlight() {
            if highlightState == .partial {
                var attributes = defaultTypingAttributes
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                attributes[.foregroundColor] = UIColor(.foreground)
                textStorage.setAttributes(attributes, range: range)
            }
            
            highlightState = .full
        }
        
        func highlightSelectedParagraph() {
            let textView = self
            let text = textView.text!
            let selectedRange = textView.selectedRange
            
            if focusType == .typeWriter {
                resetHighlight()
                return
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
            highlightRange(paragraph)
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

extension UIScrollView {
    func resetScrollIndicators() {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        verticalScrollIndicatorInsets.bottom = (scene?.windows.first?.safeAreaInsets.bottom ?? 0) + 4
        verticalScrollIndicatorInsets.top = max(scene?.windows.first?.safeAreaInsets.top ?? 0, 20)
    }
    
    func padScrollIndicators() {
        verticalScrollIndicatorInsets.top = 74
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
