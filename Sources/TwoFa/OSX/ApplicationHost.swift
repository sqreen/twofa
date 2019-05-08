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

var GLOBAL_SHOULD_QUIT = false

class ApplicationHost: ApplicationHostProtocol {
    
    var shouldQuit: Bool {
        return GLOBAL_SHOULD_QUIT
    }
    
    func run(_ callback: @escaping AppCallback) {
        
        signal(SIGINT) { signal in
            if GLOBAL_SHOULD_QUIT {
                print("Exiting because previous SIGINT not honored...")
                exit(130)
            } else {
                GLOBAL_SHOULD_QUIT = true
            }
        }
        
        DispatchQueue.global().async {
            callback()
        }
        
        RunLoop.current.run(mode: .default, before: .distantFuture)
    }
}
#endif
