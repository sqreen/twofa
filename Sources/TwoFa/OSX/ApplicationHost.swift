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
import KeychainAccess

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

                let keychain = Keychain(service: "com.example.github-token")

                DispatchQueue.global().sync {
                    do {
                        // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`

                        print("Getting...")
                        let password = try keychain
                            .authenticationPrompt("load an item from the keychain")
                            .get("kishikawakatsumi")

                        print("Got password: \(password)")

                        print("Setting...")
                        try keychain
                            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                            .set("01234567-89ab-cdef-0123-456789abcdef", key: "kishikawakatsumi")
                        print("Set")
                    } catch let error {
                        // Error handling if needed...
                        print("Error: \(error)")
                    }
                }

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
