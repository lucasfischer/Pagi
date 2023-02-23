//
//  Scene+windowNotResizable.swift
//  Pagi
//
//  Created by Lucas Fischer on 23.02.23.
//

import SwiftUI

#if os(macOS)
@available(macOS, deprecated: 13.0, message: "Scene+windowNotResizable extension is only useful when targeting macOS versions earlier than 13")
extension Scene {
    
    func windowNotResizable() -> some Scene {
        if #available(macOS 13.0, *) {
            return self.windowResizability(.contentSize)
        } else {
            return self
        }
    }
    
}
#endif
