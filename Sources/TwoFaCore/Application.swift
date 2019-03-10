import Commander

import CoreImage
import AppKit

public class Application {

    let appHost: ApplicationHost

    public init(appHost: ApplicationHost) {
        self.appHost = appHost
    }

    public func run() {
        let group = Group {
            $0.command("list") {
                fatalError("Not implemented")
            }
            
            $0.command(
                "add",
                Argument<String>("name", description: "Your name"),
                Option<String?>("seed", default: nil, description: "Your name")
            ) { (name: String, seed: String?) in
                
                let semaphore = DispatchSemaphore(value: 0)
                var screenshotDetector: ScreenshotDetector? = nil
                DispatchQueue.main.async {
                    screenshotDetector = ScreenshotDetector()
                    screenshotDetector?.newFileCallback = { fileURL in
                        print("Got screenshot: \(fileURL)")
                        
                        do {
                            print("Parsed: \(String(describing: try fileURL.parseQR()))")
                        } catch {
                            print("Invalid screenshot")
                        }
                        
                        
                        semaphore.signal()
                    }
                }
                print("Adding \(name)...")
                
                print("Waiting...")
                semaphore.wait()
                print("End of semaphore")
            }
        }
        
        self.appHost.run { group.run() }
    }

}




extension NSURL {
    func parseQR() throws -> OtpAuth? {

        guard let image = CIImage(contentsOf: self as URL) else {
            return nil
        }

        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

        let features = detector?.features(in: image) ?? []

        let parser = OtpAuthStringParser()
        let otpStrings = features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
        
        for otpAuthStr in otpStrings {
            return try parser.parse(otpAuthStr)
        }
        
        return nil
    }
}
