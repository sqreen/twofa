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
                Option<String?>("label", default: .none),
                Option<String?>("secret", default: .none),
                Option<String?>("uri", default: .none)
            ) { label, secretStr, uri in
                
                do {
                    let otpAuth: OtpAuth
                    if let uri = uri {
                        otpAuth = try OtpAuth(uri: uri, label: label)
                    } else if let secretStr = secretStr, let label = label {
                        otpAuth = try OtpAuth(label: label, secretStr: secretStr)
                    } else {
                        otpAuth = try self.source.getInLoopSync(label: label)
                    }
                    //                    guard !self.keychain.get(otpAuth.label) else {
                    //                        print("Item named \(otpAuth.label) already exists in the list. Pass in the --name parameter to override the name.")
                    //                        return
                    //                    }

                    // demo1: otpauth://totp/avi-9605?secret=LZYSI2TSMRSWOYJSPEYSM5Q&issuer=SparkPost
                    // demo2: --name Poloniex --secret 2FULJJMNMVVDYXLTV
                    try self.keychain.add(KeychainItem(from: otpAuth))
                } catch OtpAuthStringParser.ParseError.notAnUrl(let u) {
                    print("Invalid URI: \(u)")
                } catch OtpAuthStringParser.ParseError.invalidScheme(let s) {
                    print("Invalid URI scheme. Expected 'otpauth' but received '\(s)'")
                } catch OtpAuthStringParser.ParseError.invalidSecret(let s) {
                    print("Invalid secret. Secret must be a valid Base32-encoded string. Received: '\(s)'")
                } catch {
                    print("Unexpected error: \(error)")
                }
            }
        }
        
        self.appHost.run { group.run() }
    }
}



