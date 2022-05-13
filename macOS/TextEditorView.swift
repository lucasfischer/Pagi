//
//  TextEditorView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI

// MARK: - View
struct TextEditorView: NSViewControllerRepresentable {
    @Binding var text: String
    var font: String
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    @Binding var focusMode: Bool
    
    func makeNSViewController(context: Context) -> NSViewController {
        let vc = TextEditorController()
        vc.textView.delegate = context.coordinator
        return vc
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        guard let vc = nsViewController as? TextEditorController else { return }
        
        if text != vc.textView.string {
            vc.textView.string = text
        }
        
        if focusMode != vc.focusMode {
            vc.focusMode = focusMode
            if focusMode {
                vc.enableFocusMode()
            } else {
                vc.resetFocusMode()
            }
        }
        
        vc.textView.isContinuousSpellCheckingEnabled = isSpellCheckingEnabled
        vc.textView.isGrammarCheckingEnabled = isSpellCheckingEnabled
        vc.isSpellCheckingEnabled = isSpellCheckingEnabled
    }
}

// MARK: - Coordinator
extension TextEditorView {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, font: font, size: size, isSpellCheckingEnabled: isSpellCheckingEnabled)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorView
        var font: String
        var size: CGFloat
        var isSpellCheckingEnabled: Bool
        var selectedRanges: [NSValue] = []
        
        var attributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineHeightMultiple = 1.3
            paragraphStyle.lineSpacing = 4
            
            return  [
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                NSAttributedString.Key.font : NSFont(name: font, size: size)!,
                NSAttributedString.Key.foregroundColor: NSColor(.foreground)
            ]
        }
        
        init(_ parent: TextEditorView, font: String, size: CGFloat, isSpellCheckingEnabled: Bool) {
            self.parent = parent
            self.font = font
            self.size = size
            self.isSpellCheckingEnabled = isSpellCheckingEnabled
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textView(_ textView: NSTextView, shouldChangeTypingAttributes oldTypingAttributes: [String : Any] = [:], toAttributes newTypingAttributes: [NSAttributedString.Key : Any] = [:]) -> [NSAttributedString.Key : Any] {
            
            return attributes
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            if !parent.focusMode {
                return
            }
            
            guard let textView = notification.object as? TextEditorController.CustomTextView else { return }
            
            textView.highlightSelectedParagraph()
            textView.focusSelection(animate: true)
        }
    }
}

// MARK: - Controller
fileprivate final class TextEditorController: NSViewController {
    var isSpellCheckingEnabled: Bool = false
    var focusMode: Bool = false
    let textView = CustomTextView()
    let scrollView = NSScrollView()
    
    var textContainerInset: NSSize {
        let frameWidth = self.view.frame.size.width
        let frameHeight = self.view.frame.size.height
        let horizontalPadding = max(((frameWidth - 650) / 2), 16)
        
        if focusMode {
            return NSSize(width: horizontalPadding, height: frameHeight / 2)
        }
        else {
            return NSSize(width: horizontalPadding, height: 32)
        }
    }
    
    override func loadView() {
        // - ScrollView
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.lineScroll *= 2
        
        // - TextView
        textView.autoresizingMask = [.width]
        textView.allowsUndo = true
        textView.textColor = NSColor(.foreground)
        textView.isRichText = false
        textView.insertionPointColor = .controlAccentColor
        textView.isContinuousSpellCheckingEnabled = isSpellCheckingEnabled
        textView.isGrammarCheckingEnabled = isSpellCheckingEnabled
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        
        self.view = scrollView
    }
    
    // Center NSTextView in NSScrollView
    override func viewWillLayout() {
        super.viewWillLayout()
        textView.textContainerInset = textContainerInset
    }
    
    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(self.view)
    }
    
    func resetFocusMode() {
        let origin = textView.textContainerOrigin
        textView.textContainerInset = textContainerInset
        textView.resetHighlight()
        
        // Fix scroll offset
        let offset = textView.textContainerOrigin.y - origin.y
        let point = NSPoint(x: 0, y: scrollView.contentView.bounds.origin.y + offset)
        scrollView.scroll(to: point, animationDuration: 0)
        
        // Remove Observer
        NotificationCenter.default.removeObserver(self)
    }
    
    func enableFocusMode() {
        textView.textContainerInset = textContainerInset
        textView.highlightSelectedParagraph()
        textView.focusSelection()
        
        // Add Observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStartedScrolling),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )
    }
    
    @objc
    func onStartedScrolling(_ notification: Notification) {
        textView.resetHighlight()
    }
    
    class CustomTextView: NSTextView {
        var caretSize: CGFloat = 3
        
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
        
        func focusSelection(animate: Bool = false) {
            let textView = self
            
            let insertionRect = textView.layoutManager?.boundingRect(forGlyphRange: textView.selectedRange(), in: textView.textContainer!)
            guard let rect = insertionRect,
                  let scrollView = textView.enclosingScrollView
            else { return }
            
            let point = NSPoint(x: 0, y: rect.origin.y + rect.size.height)
            scrollView.scroll(to: point, animationDuration: animate ? 0.2 : 0)
        }
        
        func resetHighlight() {
            let textView = self
            if let str = textView.string as NSString?,
               let textStorage = textView.textStorage {
                textStorage.addAttribute(.foregroundColor, value: NSColor(.foreground), range: NSRange(location: 0, length: str.length))
            }
        }
        
        func highlightSelectedParagraph() {
            let textView = self
            
            if let str = textView.string as NSString?,
               let textStorage = textView.textStorage {
                let selectedRange = textView.selectedRange()
                
                let paragraph = str.paragraphRange(for: selectedRange)
                
                textStorage.addAttribute(.foregroundColor, value: NSColor(.foregroundFaded), range: NSRange(location: 0, length: str.length))
                textStorage.addAttribute(.foregroundColor, value: NSColor(.foreground), range: paragraph)
            }
        }
    }
    
}

extension NSScrollView {
    func scroll(to point: NSPoint, animationDuration: Double) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = animationDuration
        contentView.animator().setBoundsOrigin(point)
        reflectScrolledClipView(contentView)
        NSAnimationContext.endGrouping()
    }
}
