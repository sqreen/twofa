//
//  PasteboardOtpAuthSource.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation
import CoreImage
import TwoFaCore

public class PasteboardOtpAuthSource : OtpAuthSource {
    
    let pb: PasteboardWatcher
    
    init(pb: PasteboardWatcher) {
        self.pb = pb
    }
    
    public func getSync(nameHint: String?) throws -> OtpAuth? {
        
        defer { self.pb.delegate = nil }
        
        class PBWDelegate : PasteboardWatcherDelegate {
            let semaphore: DispatchSemaphore
            var result: OtpAuth?
            var error: Error?
            var nameHint: String?
            
            func newlyCopiedCImageObtained(_ image: CIImage) {
                defer {
                    semaphore.signal()
                }
                
                do {
                    self.result = try image.parseQR(nameHint: nameHint)
                } catch let error {
                    self.error = error
                }
            }
            
            init(_ semaphore: DispatchSemaphore, nameHint: String?) {
                self.semaphore = semaphore
                self.nameHint = nameHint
            }
        }
        
        
        let semaphore = DispatchSemaphore(value: 0)
        let delegate = PBWDelegate(semaphore, nameHint: nameHint)
        self.pb.delegate = delegate
        
        print("Please take a screenshot of a 2FA QR code...")
        semaphore.wait()
        
        if let error = delegate.error {
            throw error
        }
        
        if let result = delegate.result {
            print("Found: \(result.label)")
        } else {
            print("A screenshot was detected, but it does not contain a valid 2FA QR code")
        }
        
        return delegate.result
    }
}
