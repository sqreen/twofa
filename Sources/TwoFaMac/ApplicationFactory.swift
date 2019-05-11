//
//  ApplicationFactory.swift
//  TwoFaMac
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
        let pb = PasteboardWatcher()
        let source = PasteboardOtpAuthSource(pb: pb)
        return Application(appHost: host, keychain: MacKeychain(), source: source, outputs: [PasteboardOutputChannel(), StdoutOutputChannel()])
    }
}
