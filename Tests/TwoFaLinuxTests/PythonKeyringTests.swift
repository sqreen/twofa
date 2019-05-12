//
//  TwoFaLinuxTests.swift
//  TwoFaLinuxTests
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import XCTest
@testable import TwoFaLinux

class PythonKeyringTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Can we init on this system? Depends on Python3 being used by PythonKit
    func testInit() throws {
        try PythonKeyring()
    }

    static var allTests = [
        ("testInit", testInit),
    ]
}
