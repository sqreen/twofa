//
//  PythonKeyring.swift
//  TwoFaLinux
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import Foundation
import PythonKit
import TwoFaCore

public class PythonKeyring : Keychain {
    
    public enum Error : Swift.Error {
        case missingKeyringModule
    }
    
    static let service = "org.janiskirsteins.twofa"
    
    let keyring: PythonObject
    
    public init() throws {
        let modName = "keyring"
        
        let sys = Python.import("importlib")
        if sys.util.find_spec("keyring") == Python.None {
            throw Error.missingKeyringModule
        }
        
        self.keyring = Python.import(modName)
    }
    
    public func enumerateLabels() throws -> [String] {
        print("stub: enumerate functionality not implemented")
        print("see: https://github.com/jaraco/keyring/issues/238")
        return []
    }
    
    public func add(_ item: KeychainItem) throws {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(item)
        self.keyring.set_password(PythonKeyring.service, item.otp.label, String(data: jsonData, encoding: .utf8))
    }
    
    public func get(_ label: String) throws -> KeychainItem {
        
        let jsonPyStr = self.keyring.get_password(PythonKeyring.service, label)
        
        guard jsonPyStr != Python.None else {
            throw KeychainError.itemNotFound
        }
        
        let jsonStr = String(describing: jsonPyStr)
        
        if let data = jsonStr.data(using: .utf8) {
            return try JSONDecoder().decode(KeychainItem.self, from: data)
        }
        
        throw KeychainError.invalidData("Corrupt data (non-utf8) found.")
    }
    
    public func removeWithAuth(_ label: String) throws {
        self.keyring.delete_password(PythonKeyring.service, label)
    }
    
    public func selfTest() throws {
        print("stub: not implemented")
    }
    
    
}

