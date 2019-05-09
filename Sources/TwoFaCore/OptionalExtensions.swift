//
//  OptionalExtensions.swift
//  Commander
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Commander
import Foundation

extension Optional where Wrapped : ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        do {
            self = .some(try Wrapped(parser: parser))
        } catch ArgumentError.missingValue {
            self = .none
        } catch {
            throw error
        }
    }
}

extension Optional where Wrapped : CustomStringConvertible {
    public var description: String {
        switch self {
        case .some(let value):
            return value.description
        case .none:
            return ""
        }
    }
}

#if swift(>=4.1)
extension Array : ArgumentConvertible where Element : ArgumentConvertible {}
extension Optional : ArgumentConvertible where Wrapped : ArgumentConvertible {}
extension Optional : CustomStringConvertible where Wrapped : CustomStringConvertible {}
#endif
