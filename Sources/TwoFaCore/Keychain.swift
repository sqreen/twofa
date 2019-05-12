//
//  Keychain.swift
//  Base32
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation

public protocol Keychain {
    func enumerateLabels() throws -> [String]
    func add(_ item: KeychainItem) throws
    func get(_ label: String) throws -> KeychainItem
    func removeWithAuth(_ label: String) throws
    func selfTest() throws
}

public enum KeychainError : Error {
    case duplicateItem
    case itemNotFound
    case invalidData(_ msg: String)
}
