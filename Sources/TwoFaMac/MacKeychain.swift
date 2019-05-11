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
    static let itemService = "org.janiskirsteins.twofa-items"
    static let selfTestPrompt = "test keychain access permission"
    
    private func itemPrompt(_ label: String) -> String {
        return "access the account '\(label)'"
    }
    
    private func removePrompt(_ label: String) -> String {
        return "remove the account '\(label)'"
    }
    
    private func presenceTestPrompt(_ label: String) -> String {
        return "check if the account '\(label)' exists"
    }
    
    /// Add an item to the keychain
    func add(_ item: KeychainItem) throws {
        try addCodable(service: MacKeychain.itemService, label: item.otp.label, item: item)
    }
    
    /// Self test (to see if the entitlements are working correctly)
    func selfTest() throws {
        defer {
            do {
                try remove(service: MacKeychain.itemService, label: "___selftest___")
            } catch {
                print("Failed to clean up: \(error)")
            }
        }
        
        try addCodable(service: MacKeychain.itemService, label: "___selftest___", item: ["Hello World"])
        let retrieved: [String] = try getCodable(service: MacKeychain.itemService, label: "___selftest___", prompt: MacKeychain.selfTestPrompt)
        assert(retrieved == ["Hello World"])
    }
    
    private func addCodable<T: Encodable>(service: String, label: String, item: T) throws {
        let keychain = _KeychainLib(service: service)
        
        var errorToReraise: Error? = nil
        
        DispatchQueue.global().sync {
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(item)
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(jsonData, key: label)
            } catch KeychainAccess.Status.duplicateItem {
                errorToReraise = KeychainError.duplicateItem
            } catch let error {
                // Error handling if needed...
                errorToReraise = error
            }
        }
        
        if let error = errorToReraise {
            throw error
        }
    }
    
    private func remove(service: String, label: String) throws {
        let keychain = _KeychainLib(service: service)
        try keychain.remove(label)
    }
    
    public func removeWithAuth(_ label: String) throws {
        let keychain = _KeychainLib(service: MacKeychain.itemService)
        if keychain.authenticationPrompt(presenceTestPrompt(label)).allKeys().contains(label) {
            try remove(service: MacKeychain.itemService, label: label)
        } else {
            throw KeychainError.itemNotFound
        }
    }
    
    func get(_ label: String) throws -> KeychainItem {
        return try self.getCodable(service: MacKeychain.itemService, label: label, prompt: itemPrompt(label))
    }
    
    private func getCodable<T: Decodable>(service: String, label: String, prompt: String) throws -> T  {
        var errorToReraise: Error? = nil
        var result: T? = nil
        
        DispatchQueue.global().sync {
            do {
                guard let jsonStr = try _KeychainLib(service: service)
                    .authenticationPrompt(prompt)
                    .get(label) else {
                    return
                }
                
                if let data = jsonStr.data(using: .utf8) {
                    result = try JSONDecoder().decode(T.self, from: data)
                }
            } catch KeychainAccess.Status.itemNotFound {
                errorToReraise = KeychainError.itemNotFound
            } catch let error {
                errorToReraise = error
            }
        }
        
        if let error = errorToReraise {
            throw error
        }
        
        if let result = result {
            return result
        }
        
        throw KeychainError.itemNotFound
    }
    
    public func enumerateLabels() throws -> [String] {
        return Array(_KeychainLib(service: MacKeychain.itemService).allKeys())
    }
}
