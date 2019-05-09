//
//  PasteboardOutputChannel.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 08/05/2019.
//

import Foundation
import TwoFaCore
import AppKit

public class PasteboardOutputChannel : OutputChannel {
    var oldContents: String? = nil
    
    public func open() {
        self.oldContents = NSPasteboard.general.string(forType: .string)
        print("The current code will be automatically synced to the pasteboard. Previous pasteboard content will be restored afterwards.")
    }
    
    public func send(_ code: String, remaining: TimeInterval) {
        self.set(code)
    }
    
    public func close() {
        print("Restoring the previous pasteboard content.")
        self.set(self.oldContents)
    }
    
    private func set(_ val: String?) {
        NSPasteboard.general.clearContents()
        if let val = val {
            NSPasteboard.general.setString(val, forType: .string)
        }
    }
}
