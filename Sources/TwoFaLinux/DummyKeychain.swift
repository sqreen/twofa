//
//  DummyKeychain.swift
//  TwoFaLinux
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import Foundation
import TwoFaCore

public class DummyKeychain : Keychain {
    public func enumerateLabels() throws -> [String] {
        return ["not@implemented.com"]
    }
    
    public func add(_ item: KeychainItem) throws {
        print("todo: implement keychain add")
    }
    
    public func get(_ label: String) throws -> KeychainItem {
        let dummyOtpAuth = try OtpAuth(uri: "otpauth://totp/dummy?secret=LZYSI2TSMRSWOYJSPEYSM5Q&issuer=Sqreen", label: "dummy@example.com")
        return KeychainItem(from: dummyOtpAuth)
    }
    
    public func removeWithAuth(_ label: String) throws {
        print("todo: implement keychain removal")
    }
    
    public func selfTest() throws {
        print("OK")
    }
}
