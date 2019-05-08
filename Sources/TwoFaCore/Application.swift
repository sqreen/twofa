import Commander

import CoreImage
import OneTimePassword
import AppKit

public class Application {

    let appHost: ApplicationHost
    let keychain: Keychain
    let source: OtpAuthSource
    let outputs: [OutputChannel]
    
    public init(appHost: ApplicationHost, keychain: Keychain, source: OtpAuthSource, outputs: [OutputChannel]) {
        self.appHost = appHost
        self.keychain = keychain
        self.source = source
        self.outputs = outputs
    }
    
    public func run() {
        
        let group = Group {
            $0.command("list") {
                do {
                    for item in try self.keychain.enumerateLabels() {
                        print(item)
                    }
                } catch {
                    print("Failed to list the items: \(error)")
                }
            }
            
            $0.command("get", Argument<String>("label")) { label in
                do {
                    let item = try self.keychain.get(label) 
                    
                    guard case .totp(let period) = item.otp.type else {
                        fatalError("HOTP not implemented")
                    }
                    
                    guard let generator = Generator(
                        factor: .timer(period: TimeInterval(period)),
                        secret: Data(item.otp.secret),
                        algorithm: .sha1,
                        digits: item.otp.digits.rawValue) else {
                            fatalError("Invalid generator parameters")
                    }
                    
                    for c in self.outputs { c.open() }
                    defer { for c in self.outputs { c.close()} }
                    
                    repeat {
                        let remaining = TimeInterval(period) - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: TimeInterval(period))
                        let code = try generator.successor().password(at: Date())
                        for c in self.outputs { c.send(code, remaining: remaining) }
                        sleep(1)
                    } while !self.appHost.shouldQuit
                } catch KeychainError.itemNotFound {
                    print("Specified item (\(label)) not found")
                } catch {
                    print("Unexpected error: \(error)")
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
                    
                    // demo1: otpauth://totp/avi-9605?secret=LZYSI2TSMRSWOYJSPEYSM5Q&issuer=SparkPost
                    // demo2: --name Poloniex --secret 2FULJJMNMVVDYXLTV
                    let item = KeychainItem(from: otpAuth)
                    try self.keychain.add(item)
                } catch OtpAuthStringParser.ParseError.notAnUrl(let u) {
                    print("Invalid URI: \(u)")
                } catch OtpAuthStringParser.ParseError.invalidScheme(let s) {
                    print("Invalid URI scheme. Expected 'otpauth' but received '\(s)'")
                } catch OtpAuthStringParser.ParseError.invalidSecret(let s) {
                    print("Invalid secret. Secret must be a valid Base32-encoded string. Received: '\(s)'")
                } catch KeychainError.duplicateItem {
                    print("Item with this label already exists. If you want to add it, pass a unique value for the --label option.")
                } catch {
                    print("Unexpected error: \(error)")
                }
            }
        }
        
        self.appHost.run { group.run() }
    }
}



