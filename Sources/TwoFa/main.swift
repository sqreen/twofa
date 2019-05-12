import Foundation
import TwoFaCore

#if os(macOS)
import TwoFaMac
#elseif os(Linux)
import TwoFaLinux
#endif

do {
    let app = try ApplicationFactory().create()
    app.run()
} catch {
    print("Could not initialize application dependencies: \(error)")
}
