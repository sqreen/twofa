//
//  OutputChannel.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 08/05/2019.
//

import Foundation

public protocol OutputChannel {
    func open()
    func send(_ code: String, remaining: TimeInterval)
    func close()
}

public extension OutputChannel {
    public func open() {}
    public func close() {}
}

public class StdoutOutputChannel : OutputChannel {
    public init() {
        
    }
    
    public func open() {
        print("")
    }
    
    public func send(_ code: String, remaining: TimeInterval) {
        print("\rCode (\(remaining < 10 ? "0" : "")\(Int(remaining))s): \(code)", terminator: "")
        fflush(__stdoutp)
    }
    
    public func close() {
        print("")
    }
}
