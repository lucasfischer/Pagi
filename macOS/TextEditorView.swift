import SwiftUI
import NaturalLanguage
import PagiKit

// MARK: - View
struct TextEditorView: NSViewControllerRepresentable {
    @Binding var text: String
    var colors: Theme.Colors
    var font: iAFont
    var size: CGFloat
    var isSpellCheckingEnabled: Bool = false
    @Binding var focusMode: Bool
    var focusType: FocusType
    var shouldHideToolbar: Binding<Bool> = .constant(false)
    
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
        
        if colors != vc.textView.colors {
            context.coordinator.colors = colors
            vc.textView.setColors(colors)
        }
        
        if focusMode != vc.focusMode {
            vc.focusMode = focusMode
            vc.textView.focusMode = focusMode
            if focusMode {
                vc.enableFocusMode()
            } else {
                vc.resetFocusMode()
            }
        }
        if focusType != vc.textView.focusType {
            vc.textView.focusType = focusType
            if focusMode {
                vc.textView.highlightSelectedParagraph()
            }
        }
        
        if !context.coordinator.selectedRanges.isEmpty {
            vc.textView.selectedRanges = context.coordinator.selectedRanges
        }
        
        vc.textView.isContinuousSpellCheckingEnabled = isSpellCheckingEnabled
        vc.textView.isGrammarCheckingEnabled = isSpellCheckingEnabled
        vc.isSpellCheckingEnabled = isSpellCheckingEnabled
    }
}

// MARK: - Coordinator
extension TextEditorView {
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            self,
            colors: colors,
            font: font,
            size: size,
            isSpellCheckingEnabled: isSpellCheckingEnabled
        )
    }
    
    @MainActor
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorView
        var colors: Theme.Colors
        var font: iAFont
        var size: CGFloat
        var isSpellCheckingEnabled: Bool
        var selectedRanges: [NSValue] = []
        
        private let textViewUndoManager = UndoManager()
        
        var attributes: [NSAttributedString.Key : Any] {
            font.attributes(forSize: size, color: colors.foreground)
        }
        
        init(_ parent: TextEditorView, colors: Theme.Colors, font: iAFont, size: CGFloat, isSpellCheckingEnabled: Bool) {
            self.parent = parent
            self.colors = colors
            self.font = font
            self.size = size
            self.isSpellCheckingEnabled = isSpellCheckingEnabled
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.selectedRanges = textView.selectedRanges
        }
        
        func textView(_ textView: NSTextView, shouldChangeTypingAttributes oldTypingAttributes: [String : Any] = [:], toAttributes newTypingAttributes: [NSAttributedString.Key : Any] = [:]) -> [NSAttributedString.Key : Any] {
            
            return attributes
        }
        
        func undoManager(for view: NSTextView) -> UndoManager? {
            textViewUndoManager
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
        textView.drawsBackground = false
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
        
        // Add Observers
        // Start Scrolling
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStartedScrolling),
            name: NSScrollView.willStartLiveScrollNotification,
            object: scrollView
        )
    }
    
    @objc
    func onStartedScrolling(_ notification: Notification) {
        textView.resetHighlight()
    }
    
    class CustomTextView: NSTextView {
        var focusMode = false
        var focusType: FocusType = .sentence
        var colors = Theme.system.colors
        
        private var caretSize: CGFloat = 3
        private var mouseWasDown = false
        private var focusTask: Task<Void, Never>?
        
        func setColors(_ colors: Theme.Colors) {
            self.colors = colors
            
            self.insertionPointColor = NSColor(colors.accent)
            self.textColor = NSColor(colors.foreground)
            self.selectedTextAttributes = [.backgroundColor: NSColor(colors.accent.opacity(0.25))]
            
            if focusMode {
                highlightSelectedParagraph()
            } else {
                resetHighlight()
            }
        }
        
        private func setTemporaryForegroundColor(
            _ color: Color,
            forCharacterRange: NSRange? = nil
        ) {
            // Setting temporary attributes seems to yield great performance benefits compared to updating
            // normal attributes. Apple describes them as follows:
            // "Temporary attributes are used only for onscreen drawing and are not persistent in any way.
            // NSTextView uses them to color misspelled words when continuous spell checking is enabled.
            // Currently the only temporary attributes recognized are those that do not affect layout
            // (colors, underlines, and so on)."
            
            // Use full string range if none was provided
            let range = forCharacterRange ?? NSRange(string.startIndex..<string.endIndex, in: string)
            
            layoutManager?.addTemporaryAttribute(
                .foregroundColor,
                value: NSColor(color),
                forCharacterRange: range
            )
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
            setTemporaryForegroundColor(colors.foreground)
        }
        
        func highlightSelectedParagraph() {
            let textView = self
            let text = textView.string
            let selectedRange = textView.selectedRange()
            
            if focusType == .typeWriter {
                setTemporaryForegroundColor(colors.foreground)
                return
            } else {
                setTemporaryForegroundColor(colors.foregroundFaded)
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
            setTemporaryForegroundColor(colors.foreground, forCharacterRange: paragraph)
        }
        
        override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
            super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
            
            // Stop exectution if not in focus mode
            if !focusMode {
                return
            }
            
            highlightSelectedParagraph()
            
            // If selection is done
            if !stillSelectingFlag {
                // Highlight the selected paragraph
                
                // If selection via mouse down event delay focus
                if mouseWasDown {
                    focusTask = Task {
                        do {
                            try await Task.sleep(seconds: 0.15)
                            focusSelection(animate: true)
                            mouseWasDown = false
                        }
                        catch {
                            // Cancelled Task
                        }
                    }
                }
                else {
                    focusSelection(animate: true)
                }
            }
        }
        
        override func mouseDown(with event: NSEvent) {
            // Cancel focus task
            if let task = focusTask {
                task.cancel()
                self.focusTask = nil
            }
            mouseWasDown = true // Mark selection via mouse down event
            
            super.mouseDown(with: event)
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
