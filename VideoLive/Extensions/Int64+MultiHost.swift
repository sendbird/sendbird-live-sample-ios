//
//  Int64+MultiHost.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import Foundation

extension Int64 {
    func durationText() -> String {
        let duration = self

        let convertedTime = Int(duration / 1000)
        let hour = Int(convertedTime / 3600)
        let minute = Int(convertedTime / 60) % 60
        let second = Int(convertedTime % 60)

        // update UI
        var timeText = [String]()

        timeText.append(String(format: "%02d", hour))
        timeText.append(String(format: "%02d", minute))
        timeText.append(String(format: "%02d", second))

        return timeText.joined(separator: ":")
    }
}
