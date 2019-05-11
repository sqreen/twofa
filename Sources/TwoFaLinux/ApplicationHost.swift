//
//  ApplicationHost.swift
//  TwoFaLinux
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import Foundation
import TwoFaCore

typealias ApplicationHostProtocol = TwoFaCore.ApplicationHost

var GLOBAL_SHOULD_QUIT = false

class ApplicationHost: ApplicationHostProtocol {
    
    var shouldQuit: Bool {
        return GLOBAL_SHOULD_QUIT
    }
    
    func run(_ callback: @escaping AppCallback) {
        callback()
    }
}
