//
//  TextEditorView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - View
struct TextEditorView: NSViewControllerRepresentable {
    @Binding var text: String
    var viewModel: EditorViewModel
    
    func makeNSViewController(context: Context) -> NSViewController {
        let vc = TextEditorController(viewModel: viewModel)
        vc.textView.delegate = context.coordinator
        return vc
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        guard let vc = nsViewController as? TextEditorController else { return }
        
        if text != vc.textView.string {
            vc.textView.string = text
        }
        
        vc.textView.isContinuousSpellCheckingEnabled = viewModel.isSpellCheckingEnabled
        vc.textView.isGrammarCheckingEnabled = viewModel.isSpellCheckingEnabled
    }
}

// MARK: - Coordinator
extension TextEditorView {
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            self,
            viewModel: viewModel
        )
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorView
        var viewModel: EditorViewModel
        var selectedRanges: [NSValue] = []
        
        var attributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineHeightMultiple = 1.3
            paragraphStyle.lineSpacing = 4
            
            return  [
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                NSAttributedString.Key.font : NSFont(name: viewModel.font.fileName, size: CGFloat(viewModel.fontSize))!,
                NSAttributedString.Key.foregroundColor: NSColor(.foreground)
            ]
        }
        
        init(_ parent: TextEditorView, viewModel: EditorViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
            
            if let window = textView.window {
                viewModel.hideTitleBar(window: window)
            }
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            // ignore if typewriter mode is not enabled
            if !viewModel.isTypeWriterModeEabled {
                return true
            }
            
            guard let text = replacementString, let textStorage = textView.textStorage else {
                return false
            }
            
            let isAtEndOfText = textView.selectedRange().lowerBound == textStorage.length
            if isAtEndOfText && !text.isEmpty {
                // If changing text at the end of the string allow replacement
                return true
            } else {
                // Otherwise set cursor to last character and reject the replacement
                let lastCharacterRange = NSRange(location: textStorage.length, length: 0)
                textView.setSelectedRange(lastCharacterRange)
                
                return false
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
        }
        
        func textView(_ textView: NSTextView, shouldChangeTypingAttributes oldTypingAttributes: [String : Any] = [:], toAttributes newTypingAttributes: [NSAttributedString.Key : Any] = [:]) -> [NSAttributedString.Key : Any] {
            
            return attributes
        }
    }
}

// MARK: - Controller
fileprivate final class TextEditorController: NSViewController {
    var isSpellCheckingEnabled: Bool = false
    var textView = CustomTextView()
    var viewModel: EditorViewModel
    
    private var cancellable: Cancellable?
    
    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let scrollView = NSScrollView()
        
        // - ScrollView
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        
        // - TextView
        textView.autoresizingMask = [.width]
        textView.allowsUndo = true
        textView.textColor = NSColor(.foreground)
        textView.isRichText = false
        textView.insertionPointColor = .controlAccentColor
        textView.isContinuousSpellCheckingEnabled = isSpellCheckingEnabled
        textView.isGrammarCheckingEnabled = isSpellCheckingEnabled
        textView.setViewModel(viewModel)
        
        self.view = scrollView
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )
        
        cancellable = viewModel.$isTitleBarHidden.sink { [weak self] isTitleBarHidden in
            guard let self = self else { return }
            
            if !isTitleBarHidden {
                if let titleBarHeight = self.view.window?.titleBarHeight {
                    scrollView.scrollerInsets = .init(top: titleBarHeight, left: 0, bottom: 0, right: 0)
                }
            }
        }
        
    }
    
    @objc func scrollViewDidScroll(_ test: Any) {
        guard let window = self.view.window else { return }
        viewModel.hideTitleBar(window: window)
        
        if let scrollView = view as? NSScrollView {
            scrollView.scrollerInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    // Center NSTextView in NSScrollView
    override func viewWillLayout() {
        super.viewWillLayout()
        
        let frameWidth = self.view.frame.size.width
        
        let horizontalPadding = (frameWidth - 650) / 2
        if horizontalPadding > 0 {
            textView.textContainerInset = NSSize(width: horizontalPadding, height: 48)
        }
        else {
            textView.textContainerInset = NSSize(width: 16, height: 16)
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(self.view)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    class CustomTextView: NSTextView {
        var viewModel = EditorViewModel()
        
        let caretSize: CGFloat = 3
        
        func setViewModel(_ viewModel: EditorViewModel) {
            self.viewModel = viewModel
        }
        
        open override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
            var rect = rect
            rect.size.width = caretSize
            super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
        }
        
        open override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
            var rect = rect
            rect.size.width += caretSize - 1
            super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
        }
        
        override func mouseMoved(with event: NSEvent) {
            guard let window = event.window else { return }
            
            if window.mouseLocationOutsideOfEventStream.y > window.frame.height - window.titleBarHeight {
                viewModel.showTitleBar(window: window)
            }
        }
    }
    
}
