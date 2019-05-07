//
//  CIImageExtensions.swift
//  TwoFa
//
//  Created by Janis Kirsteins on 07/05/2019.
//

import Foundation
import CoreImage
import TwoFaCore

extension CIImage {
    func parseQR(nameHint: String? = nil) throws -> OtpAuth? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: self) ?? []
        
        let parser = OtpAuthStringParser()
        let otpStrings = features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
        
        for otpAuthStr in otpStrings {
            return try parser.parse(otpAuthStr, nameHint: nameHint)
        }
        
        return nil
    }
}

extension NSURL {
    func parseQR() throws -> OtpAuth? {
        
        guard let image = CIImage(contentsOf: self as URL) else {
            return nil
        }
        
        return try image.parseQR()
    }
}
