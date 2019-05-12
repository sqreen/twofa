import XCTest

import TwoFaTests
import TwoFaCoreTests
import TwoFaLinuxTests

var tests = [XCTestCaseEntry]()
tests += TwoFaTests.allTests()
tests += TwoFaCoreTests.allTests()
tests += TwoFaLinuxTests.allTests()
XCTMain(tests)
