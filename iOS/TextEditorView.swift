//
//  TextEditorView.swift
//  TextEditorView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct TextEditorView: UIViewControllerRepresentable {
    @Binding var text: String
    var colors: Theme.Colors
    var font: iAFont
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    var isAutocorrectionEnabled: Bool = false
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
            if let controller = controller as? TextEditorController {
                controller.setToolbarTintColor(colors.accent)
            }
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
            view.setTypingAttributes()
            view.updateAttributes()
        }
        
        view.spellCheckingType = isSpellCheckingEnabled ? .yes : .no
        view.autocorrectionType = isAutocorrectionEnabled ? .yes : .no
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
            
            view.setContainerInsets()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            textView.verticalScrollIndicatorInsets.top = scene?.windows.first?.safeAreaInsets.top ?? 0
            textView.verticalScrollIndicatorInsets.bottom = 0
            
            Haptics.selectionChanged()
            
            // Focus selection after keyboard poped up
            if let textView = textView as? PagiTextView, textView.focusMode {
                Task {
                    try! await Task.sleep(seconds: 0.5)
                    textView.focusSelection(animated: true)
                }
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            textView.verticalScrollIndicatorInsets.top = scene?.windows.first?.safeAreaInsets.top ?? 0
            textView.verticalScrollIndicatorInsets.bottom = scene?.windows.first?.safeAreaInsets.bottom ?? 0
            
            shouldHideToolbar = false
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
            } else if lastVelocityYSign > 0 {
                shouldHideToolbar = false
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
        
        private lazy var toolbar: UIView = {
            let toolbar = UIToolbar()
            
            // Make background transparent
            toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            toolbar.backgroundColor = .clear
            toolbar.sizeToFit()
            
            // Set proper width for toolbar
            let width = UIScreen.main.bounds.size.width
            var frame = toolbar.frame
            frame.size.width = width
            toolbar.frame = frame
            
            // Set Toolbar items
            let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
            fixedSpace.width = 8
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let placeholder = UIBarButtonItem(image: UIImage(systemName: "circle"), style: .plain, target: nil, action: nil)
            if #available(iOS 16.0, *) {
                placeholder.isHidden = true
            }
            
            let moveLeft = UIBarButtonItem(image: UIImage(systemName: "arrowtriangle.left.fill"), style: .plain, target: self, action: #selector(moveToLeft(sender:)))
            let moveRight = UIBarButtonItem(image: UIImage(systemName: "arrowtriangle.right.fill"), style: .plain, target: self, action: #selector(moveToRight(sender:)))
            let dismissKeyboard = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .plain, target: self, action: #selector(closeKeyboard(sender:)))
            
            // Add find button
            if #available(iOS 16.0, *) {
                let find = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(find(sender:)))
                toolbar.items = [placeholder, fixedSpace, find, flexibleSpace, dismissKeyboard, flexibleSpace, moveLeft, fixedSpace, moveRight]
            } else {
                toolbar.items = [dismissKeyboard, flexibleSpace, moveLeft, moveRight]
            }
            
            // Use UIInputView so the background is the same background as the system keyboard
            let inputView = UIInputView(frame: toolbar.bounds, inputViewStyle: .keyboard)
            inputView.addSubview(toolbar)
            
            return inputView
        }()
        
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
            view.autocorrectionType = .default
            view.isUserInteractionEnabled = true
            view.allowsEditingTextAttributes = false
            view.isPagingEnabled = false
            view.automaticallyAdjustsScrollIndicatorInsets = false
            view.insetsLayoutMarginsFromSafeArea = false
            view.contentInsetAdjustmentBehavior = .never
            view.alwaysBounceVertical = true
            view.layoutManager.allowsNonContiguousLayout = false // Fixes jumping around in focus mode
            if #available(iOS 16, *) {
                view.isFindInteractionEnabled = true
            }
            
            // Removes the keyboard overlay when a hardware keyboard activated
            // TODO: Only remove excute when hardware keyboard is activated
            let item = view.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
            
            // Keyboard Toolbar
            if UIDevice.current.userInterfaceIdiom == .phone {
                view.inputAccessoryView = toolbar
            }
            
            view.becomeFirstResponder()
        }
        
        // Update insets when device orientation changes
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            textView.setContainerInsets(width: size.width, height: size.height)
        }
        
        @objc
        func moveToLeft(sender: UIBarButtonItem!) {
            Haptics.selectionChanged()
            
            if textView.selectedRange.location - 1 >= 0 {
                textView.selectedRange.location = textView.selectedRange.location - 1
            }
        }
        
        @objc
        func moveToRight(sender: UIBarButtonItem!) {
            Haptics.selectionChanged()
            
            if textView.selectedRange.location + 1 <= textView.textStorage.length {
                textView.selectedRange.location = textView.selectedRange.location + 1
            }
        }
        
        @objc
        func closeKeyboard(sender: UIBarButtonItem!) {
            Haptics.selectionChanged()
            textView.resignFirstResponder()
        }
        
        @available(iOS 16.0, *)
        @objc
        func find(sender: UIBarButtonItem!) {
            textView.find(sender)
        }
        
        func setToolbarTintColor(_ color: Color) {
            toolbar.tintColor = UIColor(color)
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
            selectedFont.attributes(forSize: size, color: colors.foreground)
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
            
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let safeAreaInsets = scene?.windows.first?.safeAreaInsets
            
            let isiPad = UIDevice.current.userInterfaceIdiom == .pad
            let horizontalPadding = max((frameWidth - 704) / 2, 16)
            let topPadding = isiPad ? (safeAreaInsets?.top ?? 0) + 96 : (safeAreaInsets?.top ?? 0) + 8
            let bottomPadding = isiPad ? (safeAreaInsets?.bottom ?? 0) + 40 : (safeAreaInsets?.bottom ?? 0) + 24
            let inset = UIEdgeInsets(
                top: focusMode ? frameHeight / 2 : topPadding,
                left: horizontalPadding,
                bottom: focusMode ? frameHeight / 2 : bottomPadding,
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
            if focusType == .typeWriter {
                resetHighlight()
                return
            }
            
            
            // Find range in current selection
            let granularity: UITextGranularity = focusType == .paragraph ? .paragraph : .sentence
            guard let end = selectedTextRange?.end,
                  let selectedTextRange = tokenizer.rangeEnclosingPosition(end, with: granularity, inDirection: .storage(.backward))
            else { return }
            
            let sentenceStart = selectedTextRange.start
            let sentenceEnd = selectedTextRange.end
            let location = offset(from: beginningOfDocument, to: sentenceStart)
            let length = offset(from: sentenceStart, to: sentenceEnd)
            let paragraph = NSRange(location: location, length: length)
            
            highlightRange(paragraph)
        }
        
        func focusSelection(animated: Bool = false) {
            guard let selectedTextRange = selectedTextRange else { return }
            let rect = caretRect(for: selectedTextRange.end)
            let y = rect.origin.y - bounds.height / 2
            
            UIView.animate(withDuration: animated ?  0.15 : 0) {
                self.contentOffset.y = y
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
                colors: Theme.system.colors,
                font: iAFont.duo,
                size: 18,
                isSpellCheckingEnabled: false,
                isAutocorrectionEnabled: false,
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
