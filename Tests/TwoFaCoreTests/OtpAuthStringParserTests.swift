//
//  OtpAuthStringParser.swift
//  TwoFaCoreTests
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import XCTest
@testable import TwoFaCore

class OtpAuthStringParserTests: XCTestCase {

    //Parsed: ["otpauth://totp/janis.kirsteins?secret=XYYVWSS4UV766LRN6Y7GMK5P5ERP7FAN&digits=6&issuer=Facebook"]

    func testParse_notAnUrl() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("not an url")) { error in
            if case let OtpAuthStringParser.ParseError.notAnUrl(str) = error {
                XCTAssertEqual("not an url", str)
                return
            }
            
            XCTFail()
        }
    }
    
    func testParse_noScheme() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("totp/something")) { error in
            if case OtpAuthStringParser.ParseError.missingScheme = error { return }
            XCTFail()
        }
    }
    
    func testParse_invalidScheme() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("http://totp/something")) { error in
            if case let OtpAuthStringParser.ParseError.invalidScheme(scheme) = error {
                XCTAssertEqual("http", scheme)
                return
            }
            XCTFail()
        }
    }
    
    func testParse_missingType() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth:///label?secret=GEZDGNBV")) { error in
            if case OtpAuthStringParser.ParseError.missingType = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_emptyLabel() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/?secret=GEZDGNBV")) { error in
            if case OtpAuthStringParser.ParseError.emptyLabel = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_labelNoProvider() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV")
        XCTAssertEqual("label", result.label)
        XCTAssertNil(result.issuer)
    }
    
    func testParse_labelNoProviderHasIssuer() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV&issuer=Provider1")
        XCTAssertEqual("label", result.label)
        XCTAssertEqual("Provider1", result.issuer!)
    }
    
    func testParse_labelAndProviderNoIssuer() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/Provider1:label?secret=GEZDGNBV")
        XCTAssertEqual("label", result.label)
        XCTAssertEqual("Provider1", result.issuer!)
    }
    
    func testParse_providerAndIssuerDifferent() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/Provider1:label?secret=GEZDGNBV&issuer=Provider2")) { error in
            if case OtpAuthStringParser.ParseError.mismatchedProviderAndIssuer = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_providerAndIssuerSame() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/Provider1:label?secret=GEZDGNBV&issuer=Provider1")
        XCTAssertEqual("label", result.label)
        XCTAssertEqual("Provider1", result.issuer!)
    }
    
    func testParse_unknownType() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://unknown/label?secret=GEZDGNBV")) { error in
            if case let OtpAuthStringParser.ParseError.unknownType(typeStr) = error {
                XCTAssertEqual("unknown", typeStr)
                return
            }
            XCTFail()
        }
    }
    
    func testParse_totpNoPeriod_defaultTo30() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV")
        
        guard case let OtpType.totp(period) = result.type else {
            XCTFail()
            return
        }
        XCTAssertEqual(30, period)
    }
    
    func testParse_totpInvalidPeriod() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/label?secret=GEZDGNBV&period=abc")) { error in
            if case OtpAuthStringParser.ParseError.totpInvalidPeriod = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_totpValidPeriod() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV&period=30")
        
        guard case let OtpType.totp(period) = result.type else {
            XCTFail()
            return
        }
        XCTAssertEqual(30, period)
    }
    
    func testParse_hotpMissingCounter() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://hotp/label?secret=GEZDGNBV")) { error in
            if case OtpAuthStringParser.ParseError.hotpMissingCounter = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_hotpInvalidCounter() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://hotp/label?secret=GEZDGNBV&counter=abc")) { error in
            if case OtpAuthStringParser.ParseError.hotpInvalidCounter = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_hotpValidCounter() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://hotp/label?secret=GEZDGNBV&counter=1")
        
        guard case let OtpType.hotp(counter) = result.type else {
            XCTFail()
            return
        }
        XCTAssertEqual(1, counter)
    }
    
    func testParse_algorithmSha1() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV&algorithm=sha1")
        
        XCTAssertEqual(.sha1, result.algorithm)
    }
    
    func testParse_uppercase() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("OTPAUTH://TOTP/LABEL?SECRET=GEZDIMRT&ALGORITHM=SHA512")
        
        XCTAssertEqual(.sha512, result.algorithm)
        XCTAssertEqual("LABEL", result.label)
        XCTAssertEqual([49, 50, 52, 50, 51], result.secret)
    }
    
    func testParse_algorithmSha256() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV&algorithm=sha256")
        
        XCTAssertEqual(.sha256, result.algorithm)
    }
    
    func testParse_algorithmSha512() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV&algorithm=sha512")
        
        XCTAssertEqual(.sha512, result.algorithm)
    }
    
    func testParse_invalidAlgorithm() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/label?secret=GEZDGNBV&algorithm=md5")) { error in
            if case let OtpAuthStringParser.ParseError.invalidAlgorithm(str) = error {
                XCTAssertEqual("md5", str)
                return
            }
            XCTFail()
        }
    }
    
    func testParse_defaultAlgorithm() {
        let parser = OtpAuthStringParser()
        let result = try! parser.parse("otpauth://totp/label?secret=GEZDGNBV")
        
        XCTAssertEqual(.sha1, result.algorithm)
    }
    
    func testParse_missingSecret() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/label")) { error in
            if case OtpAuthStringParser.ParseError.missingSecret = error {
                return
            }
            XCTFail()
        }
    }
    
    func testParse_invalidSecret() {
        let parser = OtpAuthStringParser()
        XCTAssertThrowsError(try parser.parse("otpauth://totp/label?secret='")) { error in
            if case let OtpAuthStringParser.ParseError.invalidSecret(str) = error {
                XCTAssertEqual("'", str)
                return
            }
            XCTFail()
        }
    }
    
    static var allTests = [
        ("testParse_notAnUrl", testParse_notAnUrl),
        ("testParse_noScheme", testParse_noScheme),
        ("testParse_invalidScheme", testParse_invalidScheme),
        ("testParse_missingType", testParse_missingType),
        ("testParse_emptyLabel", testParse_emptyLabel),
        ("testParse_labelNoProvider", testParse_labelNoProvider),
        ("testParse_labelNoProviderHasIssuer", testParse_labelNoProviderHasIssuer),
        ("testParse_labelAndProviderNoIssuer", testParse_labelAndProviderNoIssuer),
        ("testParse_providerAndIssuerDifferent", testParse_providerAndIssuerDifferent),
        ("testParse_providerAndIssuerSame", testParse_providerAndIssuerSame),
        ("testParse_unknownType", testParse_unknownType),
        ("testParse_totpNoPeriod_defaultTo30", testParse_totpNoPeriod_defaultTo30),
        ("testParse_totpInvalidPeriod", testParse_totpInvalidPeriod),
        ("testParse_totpValidPeriod", testParse_totpValidPeriod),
        ("testParse_hotpMissingCounter", testParse_hotpMissingCounter),
        ("testParse_hotpInvalidCounter", testParse_hotpInvalidCounter),
        ("testParse_hotpValidCounter", testParse_hotpValidCounter),
        ("testParse_algorithmSha1", testParse_algorithmSha1),
        ("testParse_uppercase", testParse_uppercase),
        ("testParse_algorithmSha256", testParse_algorithmSha256),
        ("testParse_algorithmSha512", testParse_algorithmSha512),
        ("testParse_invalidAlgorithm", testParse_invalidAlgorithm),
        ("testParse_defaultAlgorithm", testParse_defaultAlgorithm),
        ("testParse_missingSecret", testParse_missingSecret),
        ("testParse_invalidSecret", testParse_invalidSecret),
    ]
}
