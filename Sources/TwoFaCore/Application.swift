import Commander

import CoreImage
import OneTimePassword
import AppKit
import Base32

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
            
            $0.command("get",
                       Flag("stdout"),
                       Argument<String>("label")) { useStdout, label in
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
                    
                    // Have a cutoff date spanning at least 1 period fully, so you can not forget
                    // that the app is running and generating codes
                    let cutoffDate = Date() + TimeInterval(period)*2
                    var wasCutoff = false
                    
                    let activeOutputs = self.outputs.filter { ($0 is StdoutOutputChannel && useStdout) || !($0 is StdoutOutputChannel) }
                    
                    if !useStdout {
                        print("NOTE: not outputting the code to stdout due to lack of --stdout")
                    }
                    
                    for c in activeOutputs { c.open() }
                    defer {
                        for c in activeOutputs { c.close()}
                        if wasCutoff {
                            print("Quitting due to timeout")
                        }
                    }
                    
                    repeat {
                        let now = Date()
                        let remaining = TimeInterval(period) - now.timeIntervalSince1970.truncatingRemainder(dividingBy: TimeInterval(period))
                        let code = try generator.successor().password(at: Date())
                        for c in activeOutputs { c.send(code, remaining: remaining) }
                        
                        if now > cutoffDate {
                            wasCutoff = true
                            break
                        }
                        
                        sleep(1)
                    } while !self.appHost.shouldQuit
                } catch KeychainError.itemNotFound {
                    print("Specified item (\(label)) not found")
                } catch {
                    print("Unexpected error: \(error)")
                }
            }
            
            $0.command("rm", Argument<String>("label")) { label in
                do {
                    try self.keychain.removeWithAuth(label)
                } catch KeychainError.itemNotFound {
                    print("Item '\(label)' not found")
                }
            }
            
            $0.command(
                "add",
                Option<String?>("label", default: .none),
                Option<String?>("secret", default: .none),
                Option<String?>("uri", default: .none),
                Flag("debug", default: false)
            ) { label, secretStr, uri, debug in
                
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
                    if debug {
                        print("Adding: \(otpAuth)")
                    }
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



