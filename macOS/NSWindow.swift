//
//  NSWindow.swift
//  Pagi (macOS)
//
//  Created by Lucas Fischer on 11.02.22.
//

import AppKit
import SwiftUI

extension NSWindow {
    
    var titleBarHeight: CGFloat {
        if let windowFrameHeight = self.contentView?.frame.height {
            return windowFrameHeight - self.contentLayoutRect.height
        }
        return 24
    }
    
    func hideTitlebar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.titleVisibility = .hidden
            self.title = ""
            self.titlebarAppearsTransparent = true
            
            self.standardWindowButton(.closeButton)?.isHidden = true
            self.standardWindowButton(.miniaturizeButton)?.isHidden = true
            self.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
    
    func showTitlebar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.titleVisibility = .visible
            self.titlebarAppearsTransparent = false
            self.titlebarSeparatorStyle = .line
            
            self.standardWindowButton(.closeButton)?.isHidden = false
            self.standardWindowButton(.miniaturizeButton)?.isHidden = false
            self.standardWindowButton(.zoomButton)?.isHidden = false
            
            if let document = self.windowController?.document as? NSDocument {
                self.title = document.displayName
            }
        }
    }
    
}
