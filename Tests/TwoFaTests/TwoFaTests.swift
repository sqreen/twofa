import XCTest
import class Foundation.Bundle

final class TwoFaTests: XCTestCase {
    func testNoArguments() throws {
        #if os(Linux)
        print("Skipping on Linux")
        return
        #endif
        guard #available(macOS 10.13, *) else {
            print("Skipping on and macOS < 10.13")
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("twofa")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertNotNil(output?.range(of: "twofa\n\nCommands:\n\n    + \u{1b}[32mlist\u{1b}[0m\n    + \u{1b}[32mversion\u{1b}[0m\n    + \u{1b}[32mtest\u{1b}[0m\n    + \u{1b}[32mget\u{1b}[0m\n    + \u{1b}[32mrm\u{1b}[0m\n    + \u{1b}[32madd\u{1b}[0m\n\n"))
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testNoArguments", testNoArguments),
    ]
}
