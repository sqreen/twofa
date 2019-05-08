//
//  MacKeychain.swift
//  TwoFa
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation
import TwoFaCore
import KeychainAccess

typealias CoreKeychain = TwoFaCore.Keychain
typealias _KeychainLib = KeychainAccess.Keychain

class MacKeychain : CoreKeychain {
    func add(_ item: KeychainItem) throws {
//        let keychain = Keychain(service: item.service)
//
//        DispatchQueue.global().sync {
//            do {
//                print("Getting...")
//                let password = try keychain
//                    .authenticationPrompt("load an item from the keychain")
//                    .get("kishikawakatsumi")
//
//                print("Got password: \(password)")
//
//                print("Setting...")
//                try keychain
//                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
//                    .set("01234567-89ab-cdef-0123-456789abcdef", key: "kishikawakatsumi")
//                print("Set")
//            } catch let error {
//                // Error handling if needed...
//                print("Error: \(error)")
//            }
//        }
        fatalError("not impl")
    }
    
    let KEY = "keychainItemJson"
    
    func remove(_ service: String) throws {
        fatalError("Not implemented")
    }
    
    func get(_ service: String) throws -> KeychainItem? {
        var returnError: Error? = nil
        var keychainItem: KeychainItem? = nil
        
        DispatchQueue.global().sync {
            do {
                let jsonData = try _KeychainLib(service: service)
                    .authenticationPrompt("load an item from the keychain")
                    .get(self.KEY)
                
                if let data = jsonData?.data(using: .utf8) {
                    keychainItem = try JSONDecoder().decode(KeychainItem.self, from: data)
                }
            } catch let error {
                returnError = error
            }
        }
        
        if let keychainItem = keychainItem {
            return keychainItem
        }
        
        if let returnError = returnError {
            throw returnError
        }
        
        fatalError("Neither error nor result")
    }
    
    public func enumerate() throws -> [KeychainItem] {
        fatalError("none")
//        return [
//            KeychainItem(otpAuth: OtpAuth())
//        ]
    }
}
