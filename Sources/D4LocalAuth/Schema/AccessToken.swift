//
//  AccessToken.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//

import Foundation

public class AccessToken {

	public static func generate() -> String {
		if let a = Array<UInt8>(randomCount: 16).encode(.base64),
			let b = String(bytes: a, encoding: .utf8) {
			return b.replacingOccurrences(of: "=", with: "")
			.replacingOccurrences(of: "+", with: "-")
			.replacingOccurrences(of: "/", with: "_")
		} else {
			return ""
		}
	}


}
