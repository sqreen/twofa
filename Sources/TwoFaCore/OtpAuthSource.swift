//
//  OtpAuthSource.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation

// https://github.com/google/google-authenticator/wiki/Key-Uri-Format

enum OtpType {
    case totp(period: Int?)
    case hotp(counter: Int)
}

enum OtpDigits : String {
    case six = "6"
    case eight = "8"
}

enum OtpAlgorithm : String, Equatable {
    case sha1
    case sha256
    case sha512
}

struct OtpAuth {
    let type: OtpType
    let label: String
    let secret: [UInt8]
    let issuer: String?
    let digits: OtpDigits
    let algorithm: OtpAlgorithm
    
}

protocol OtpAuthSource {
    
}
