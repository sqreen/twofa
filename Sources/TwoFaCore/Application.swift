import Commander

import CoreImage
import AppKit

public class Application {

    let appHost: ApplicationHost
    let keychain: Keychain
    let source: OtpAuthSource
    
    public init(appHost: ApplicationHost, keychain: Keychain, source: OtpAuthSource) {
        self.appHost = appHost
        self.keychain = keychain
        self.source = source
    }

    public func run() {
        let group = Group {
            $0.command("list") {
                do {
                    for item in try self.keychain.enumerate() {
                        print(item)
                    }
                } catch {
                    print("Failed to list the items: \(error)")
                }
            }
            
            $0.command(
                "add",
                Argument<String>("name", description: "The name hint for the account (will only be used if name can not be auto-detected"),
                Option<String?>("seed", default: nil, description: "Your name")
            ) { (name: String, seed: String?) in
                
                do {
                    let otpAuth = try self.source.getInLoopSync(nameHint: name)
                    print("Adding...")
                } catch {
                    print("Failed to add the item: \(error)")
                }
            }
        }
        
        self.appHost.run { group.run() }
    }
}



