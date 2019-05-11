//
//  NotImplementedOtpAuthSource.swift
//  TwoFaLinux
//
//  Created by Janis Kirsteins on 12/05/2019.
//

import Foundation

/// Used as a placeholder 
public class NotImplementedOtpAuthSource : OtpAuthSource {
    public init() {
        
    }
    
    public func getSync(label: String?) throws -> OtpAuth? {
        fatalError("Not implemented. Please use --uri or (--name + --label) arguments")
    }
}
