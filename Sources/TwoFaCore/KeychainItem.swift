//
//  KeychainItem.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation

public struct KeychainItem : Codable {
    let otpAuth: OtpAuth
    
    public init(from otpAuth: OtpAuth) {
        self.otpAuth = otpAuth
    }
}
