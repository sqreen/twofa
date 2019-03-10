//
//  MacAppHost.swift
//  Commander
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation

public protocol ApplicationHost {
    typealias AppCallback = () -> Never
    func run(_ callback: @escaping AppCallback)
}
