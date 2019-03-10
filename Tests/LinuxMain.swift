import XCTest

import twofaTests

var tests = [XCTestCaseEntry]()
tests += twofaTests.allTests()
XCTMain(tests)