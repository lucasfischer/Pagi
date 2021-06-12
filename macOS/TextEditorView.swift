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
    }
}

// MARK: - Coordinator
extension TextEditorView {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, font: font, size: size)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorView
        var font: String
        var size: CGFloat
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
        
        init(_ parent: TextEditorView, font: String, size: CGFloat) {
            self.parent = parent
            self.font = font
            self.size = size
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
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
    var textView = CustomTextView()
    
    override func loadView() {
        let scrollView = NSScrollView()
        
        // - ScrollView
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        
        // - TextView
        textView.autoresizingMask = [.width]
        textView.allowsUndo = true
        textView.textColor = NSColor(.foreground)
        textView.isRichText = false
        textView.insertionPointColor = .controlAccentColor
        
        self.view = scrollView
    }
    
    // Center NSTextView in NSScrollView
    override func viewWillLayout() {
        super.viewWillLayout()
        
        let frameWidth = self.view.frame.size.width
        
        let horizontalPadding = (frameWidth - 650) / 2
        if horizontalPadding > 0 {
            textView.textContainerInset = NSSize(width: horizontalPadding, height: 32)
        }
        else {
            textView.textContainerInset = NSSize(width: 16, height: 16)
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(self.view)
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
    }
    
}
