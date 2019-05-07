//
//  Keychain.swift
//  Base32
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation

public protocol Keychain {
    func enumerate() throws -> [KeychainItem] 
    func add(_ item: KeychainItem) throws
    func get(_ name: String) throws -> KeychainItem?
}
