//
//  ApplicationHostImpl.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

#if os(OSX)
import Foundation
import AppKit
import TwoFaCore

typealias ApplicationHostProtocol = TwoFaCore.ApplicationHost

class ApplicationHost: NSObject, NSApplicationDelegate, ApplicationHostProtocol {
    let queue = DispatchQueue(label: "background")
    var callback: AppCallback?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        queue.async {
            if let callback = self.callback {
//                print("Running callback")
//                let result = callback()
//                print("Got callback")
//                guard result == 0 else { exit(Int32(result)) }
                
                callback()
            }
            
            NSApplication.shared.terminate(self)
        }
    }
    
    func run(_ callback: @escaping AppCallback) {
        self.callback = callback
        NSApplication.shared.delegate = self
        NSApplication.shared.run()
    }
}
#endif
