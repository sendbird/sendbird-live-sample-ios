//
//  String+MultiHost.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import UIKit

extension String {
    public var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isEmptyOrWhitespace: Bool {
        self.trimmed.isEmpty
    }

    public var collapsed: String? {
        if self.isEmptyOrWhitespace {
            return nil
        } else {
            return self.trimmed
        }
    }

    func truncating(maxBytes: Int) -> String {
        guard count > 0 else { return "" }

        var actualByteCount = count
        while actualByteCount > 0 {
            let subview = self.utf8.prefix(actualByteCount)
            if let truncatedString = String(subview) {
                return truncatedString
            } else {
                actualByteCount -= 1
            }
        }

        return ""
    }
}
