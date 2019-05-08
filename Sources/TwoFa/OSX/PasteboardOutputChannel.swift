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
    }
    
    public func send(_ code: String) {
        self.set(code)
    }
    
    public func close() {
        self.set(self.oldContents)
    }
    
    private func set(_ val: String?) {
        NSPasteboard.general.clearContents()
        if let val = val {
            NSPasteboard.general.setString(val, forType: .string)
        }
    }
}
