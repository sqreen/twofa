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
    static let metaService = "org.janiskirsteins.twofa-meta"
    static let metaSetKey = "itemSet"
    static let metaSetReadPrompt = "access the list of known services"
    static let metaSetUpdatePrompt = "update the list of known services"
    
    private func itemPrompt(label: String) -> String {
        return "access the account '\(label)'"
    }
    
    /// Add an item to the keychain. If it succeeds, update
    /// the list of accounts as well.
    ///
    /// If the list update fails, we will try to remove the just-added item as well.
    ///
    /// It's not great, but we have no way to enumerate the items in the keychain, so we have
    /// to maintain this list ourselves.
    func add(_ item: KeychainItem) throws {
//        try self.remove(service: MacKeychain.itemService, label: item.otp.label)
        
        try addCodable(service: MacKeychain.itemService, label: item.otp.label, item: item)
        do {
            try self.addMetaLabel(item.otp.label)
        } catch {
            try self.remove(service: MacKeychain.itemService, label: item.otp.label)
            throw error
        }
    }
    
    // NOTE: this can lose all the metadata, if the save doesn't succeed
    private func addMetaLabel(_ label: String) throws {
        var set = try self.getMetaSet(prompt: MacKeychain.metaSetUpdatePrompt)
        set.insert(label)
        
        try remove(service: MacKeychain.metaService, label: MacKeychain.metaSetKey)
        try addCodable(service: MacKeychain.metaService, label: MacKeychain.metaSetKey, item: set)
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
    
    func get(_ label: String) throws -> KeychainItem {
        return try self.getCodable(service: MacKeychain.itemService, label: label, prompt: itemPrompt(label: label))
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
                
                print("Loaded: \(jsonStr)")
                
                if let data = jsonStr.data(using: .utf8) {
                    print("Loaded: \(data)")
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
    
    private func getMetaSet(prompt: String = MacKeychain.metaSetReadPrompt) throws -> Set<String> {
        do {
            return try getCodable(service: MacKeychain.metaService, label: MacKeychain.metaSetKey, prompt: prompt)
        } catch KeychainError.itemNotFound {
            return Set<String>()
        }
    }
    
    public func enumerateLabels() throws -> [String] {
        return Array(try self.getMetaSet())
    }
}
