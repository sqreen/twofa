//
//  OtpAuthSource.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation

// https://github.com/google/google-authenticator/wiki/Key-Uri-Format

// Abstraction for specific input (keyboard, pasteboard...)
public protocol OtpAuthSource {
    func getSync(label: String?) throws -> OtpAuth?
    func getInLoopSync(label: String?) throws -> OtpAuth
}

public extension OtpAuthSource {
    func getInLoopSync(label: String?) throws -> OtpAuth {
        var result: OtpAuth? = nil
        repeat {
            result = try self.getSync(label: label)
        } while result == nil
        
        return result!
    }
}

public class TerminalOtpAuthSource : OtpAuthSource {
    public func getSync(label: String?) throws -> OtpAuth? {
        fatalError("Not implemented")
    }
}

public enum OtpType: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, totpParams, hotpParams
    }
    
    private enum Base : String, Codable {
        case totp
        case hotp
    }
    
    case totp(period: Int?)
    case hotp(counter: Int)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .totp(let period):
            try container.encode(Base.totp, forKey: .base)
            try container.encode(period, forKey: .totpParams)
        case .hotp(let counter):
            try container.encode(Base.hotp, forKey: .base)
            try container.encode(counter, forKey: .hotpParams)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .totp:
            let period = try container.decode(Optional<Int>.self, forKey: .totpParams)
            self = .totp(period: period)
        case .hotp:
            let counter = try container.decode(Int.self, forKey: .hotpParams)
            self = .hotp(counter: counter)
        }
    }
}

public enum OtpDigits : String, Codable {
    case six = "6"
    case eight = "8"
}

public enum OtpAlgorithm : String, Equatable, Codable {
    case sha1
    case sha256
    case sha512
}

public struct OtpAuth : Codable, CustomStringConvertible {
    public let type: OtpType
    public let label: String
    let secret: [UInt8]
    public let issuer: String?
    public let digits: OtpDigits
    public let algorithm: OtpAlgorithm
    
    public init(label: String, secretStr: String) throws {
        self = try OtpAuthStringParser().parse(label: label, secretStr: secretStr)
    }
    
    public init(uri: String, label: String?) throws {
        self = try OtpAuthStringParser().parse(uri, label: label)
    }
    
    public init(type: OtpType,
                label: String,
                secret: [UInt8],
                issuer: String?,
                digits: OtpDigits,
                algorithm: OtpAlgorithm)
    {
        self.type = type
        self.label = label
        self.secret = secret
        self.issuer = issuer
        self.digits = digits
        self.algorithm = algorithm
    }
    
    public var description: String {
        get {
            return "[OtpAuth label:\(self.label)]"
        }
    }
}


