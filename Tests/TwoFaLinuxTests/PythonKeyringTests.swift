//
//  PythonKeyringTests.swift
//  PythonKeyringTests 
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import XCTest
@testable import TwoFaLinux

class PythonKeyringTests: XCTestCase {

    /// Can we init on this system? Depends on Python3 being used by PythonKit
    func testInit() throws {
        try PythonKeyring()
    }

    static var allTests = [
        ("testInit", testInit),
    ]
}

