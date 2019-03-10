//
//  UrlExtensions.swift
//  TwoFaCore
//
//  Created by Janis Kirsteins on 10/03/2019.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name.caseInsensitiveCompare(queryParamaterName) == .orderedSame })?.value
    }
}
