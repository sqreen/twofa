//
//  ApplicationFactory.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation
import TwoFaCore

public class ApplicationFactory {
    public init() {
        
    }
    
    public func create() -> Application {
        let host = ApplicationHost()
        let source = NotImplementedOtpAuthSource()
        return Application(appHost: host, keychain: DummyKeychain(), source: source, outputs: [StdoutOutputChannel()])
    }
}
