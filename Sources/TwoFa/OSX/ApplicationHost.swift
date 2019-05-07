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

class ApplicationHost: ApplicationHostProtocol {
    
    func run(_ callback: @escaping AppCallback) {

        DispatchQueue.global().async {
            callback()
        }
        
        RunLoop.current.run(mode: .default, before: .distantFuture)
    }
}
#endif
