import Foundation
import TwoFaCore

#if os(macOS)
import TwoFaMac
#elseif os(Linux)
import TwoFaLinux
#endif

let app = ApplicationFactory().create()
app.run()
