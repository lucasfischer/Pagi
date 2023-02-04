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
    var colors: Theme.Colors
    var font: iAFont
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
        
        if view.colors != colors {
            view.setColors(colors)
        }
        
        if view.selectedFont != font {
            view.selectedFont = font
            view.updateAttributes()
        }
        if view.size != size {
            view.size = size
            view.updateAttributes()
        }
        
        if focusMode != view.focusMode {
            context.coordinator.focusMode = focusMode
            view.focusMode = focusMode
            
            view.setContainerInsets()
            view.setTypingAttributes()
            
            view.updateAttributes(animated: true)
        }
        
        if focusType != view.focusType {
            view.focusType = focusType
            
            view.updateAttributes()
        }
        
        view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
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
            
            view.backgroundColor = UIColor(.clear)
            view.setTypingAttributes()
            view.isScrollEnabled = true
            view.isEditable = true
            view.autocorrectionType = .no // hides the predictive keyboard bar
            view.isUserInteractionEnabled = true
            view.allowsEditingTextAttributes = false
            view.isPagingEnabled = false
            view.automaticallyAdjustsScrollIndicatorInsets = false
            view.insetsLayoutMarginsFromSafeArea = false
            view.contentInsetAdjustmentBehavior = .never
            view.alwaysBounceVertical = true
            if #available(iOS 16, *) {
                view.isFindInteractionEnabled = true
            }
            
            // Removes the keyboard overlay when a hardware keyboard activated
            // TODO: Only remove excute when hardware keyboard is activated
            let item = view.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
            
            view.resetScrollIndicators()
            
            view.becomeFirstResponder()
        }
        
        // Update insets when device orientation changes
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            textView.setContainerInsets(width: size.width, height: size.height)
        }
        
    }
    
}

extension TextEditorView {
    enum HighlightState: String {
        case full
        case partial
    }
    
    class PagiTextView: UITextView {
        var selectedFont: iAFont = .duo
        var size: Double = 18
        var focusMode: Bool = false
        var focusType: FocusType = .paragraph
        var highlightState: HighlightState = .full
        var colors = Theme.system.colors
        
        var defaultTypingAttributes: [NSAttributedString.Key : Any] {
            selectedFont.attributes(forSize: size)
        }
        
        func setColors(_ colors: Theme.Colors) {
            self.colors = colors
            
            self.textColor = UIColor(colors.foreground)
            
            if focusMode {
                highlightSelectedParagraph()
            } else {
                resetHighlight()
            }
        }
        
        func setTypingAttributes() {
            typingAttributes = defaultTypingAttributes
        }
        
        func setContainerInsets(width: Double? = nil, height: Double? = nil) {
            let frameWidth = width ?? frame.size.width
            let frameHeight = height ?? frame.size.height
            
            let horizontalPadding = max((frameWidth - 704) / 2, 16)
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
            textColor = UIColor(colors.foregroundFaded)
            var attributes = defaultTypingAttributes
            attributes[.foregroundColor] = UIColor(colors.foreground)
            textStorage.setAttributes(attributes, range: range)
        }
        
        func updateAttributes(animated: Bool = false) {
            highlightState = .partial
            resetHighlight()
            
            if focusMode {
                highlightSelectedParagraph()
                focusSelection(animated: animated)
            }
        }
        
        func resetHighlight() {
            if highlightState == .partial {
                var attributes = defaultTypingAttributes
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                attributes[.foregroundColor] = UIColor(colors.foreground)
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
                colors: Theme.system.colors,
                font: iAFont.duo,
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
