//
//  OtpAuthStringParser.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation
import Base32

// Spec: https://github.com/google/google-authenticator/wiki/Key-Uri-Format

public class OtpAuthStringParser {
    
    public enum ParseError : Swift.Error {
        case notAnUrl(String)
        case missingScheme
        case invalidScheme(String)
        case missingType
        case unknownType(String)
        case hotpMissingCounter
        case hotpInvalidCounter
        case totpInvalidPeriod
        case emptyLabel
        case missingSecret
        case invalidSecret(String)
        case invalidDigits(String)
        case mismatchedProviderAndIssuer
        case invalidAlgorithm(String)
    }
    
    public init() {
        
    }
    
    public func parse(_ str: String, nameHint: String? = nil) throws -> OtpAuth {
        
        guard let url = URL(string: str) else {
            throw ParseError.notAnUrl(str)
        }
        
        guard let scheme = url.scheme else {
            throw ParseError.missingScheme
        }
        
        guard scheme.caseInsensitiveCompare("otpauth") == ComparisonResult.orderedSame else {
            throw ParseError.invalidScheme(scheme)
        }
        
        guard let typeStr = url.host else {
            throw ParseError.missingType
        }
        
        let type: OtpType
        
        switch typeStr.lowercased() {
        case "totp":
            if let periodStr = url.valueOf("period") {
                guard let period = Int(periodStr) else {
                    throw ParseError.totpInvalidPeriod
                }
                type = .totp(period: period)
            } else {
                type = .totp(period: nil)
            }
        case "hotp":
            guard let counterStr = url.valueOf("counter") else {
                throw ParseError.hotpMissingCounter
            }
            guard let counter = Int(counterStr) else {
                throw ParseError.hotpInvalidCounter
            }
            type = .hotp(counter: counter)
        default:
            throw ParseError.unknownType(typeStr)
        }
        
        let labelCandidate = String(url.path[url.path.index(after: url.path.startIndex)...])
        let label: String
        
        if labelCandidate.isEmpty {
            if let nameHint = nameHint {
                label = nameHint
            } else {
                throw ParseError.emptyLabel
            }
        } else {
            label = labelCandidate
        }
        
        let labelParts = label.split(separator: ":")
        let providerBackup: String?
        let finalLabel: String
        if labelParts.count > 1 {
            finalLabel = String(labelParts[1...].joined())
            providerBackup = String(labelParts[0])
            
            if let issuer = url.valueOf("issuer") {
                if providerBackup!.compare(issuer) != .orderedSame {
                    throw ParseError.mismatchedProviderAndIssuer
                }
            }
        } else {
            finalLabel = label
            providerBackup = nil
        }
        
        guard let secretStr = url.valueOf("secret") else {
            throw ParseError.missingSecret
        }
        
        guard let secret = base32Decode(secretStr) else {
            throw ParseError.invalidSecret(secretStr)
        }
        
        let issuer = url.valueOf("issuer") ?? providerBackup
        
        let digits : OtpDigits
        if let digitStr = url.valueOf("digits") {
            guard let digitCandidate = OtpDigits(rawValue: digitStr) else {
                throw ParseError.invalidDigits(digitStr)
            }
            digits = digitCandidate
        } else {
            digits = .six
        }
        
        let algorithm: OtpAlgorithm
        if let algoStr = url.valueOf("algorithm")?.lowercased() {
            guard let parsedAlgorithm = OtpAlgorithm(rawValue: algoStr) else {
                throw ParseError.invalidAlgorithm(algoStr)
            }
            algorithm = parsedAlgorithm
        } else {
            algorithm = .sha1
        }
        
        return OtpAuth(
            type: type,
            label: finalLabel,
            secret: secret,
            issuer: issuer,
            digits: digits,
            algorithm: algorithm)
    }
}
