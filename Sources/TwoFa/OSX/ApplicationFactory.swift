//
//  ApplicationFactory.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//
#if os(OSX)
import Foundation
import TwoFaCore

public class ApplicationFactory {
    public func create() -> Application {
        let host = ApplicationHost()
        let pb = PasteboardWatcher()
        let source = PasteboardOtpAuthSource(pb: pb)
        return Application(appHost: host, keychain: MacKeychain(), source: source, outputs: [PasteboardOutputChannel(), StdoutOutputChannel()])
    }
}
#endif
