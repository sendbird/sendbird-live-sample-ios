//
//  UIImage+Live.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/08/21.
//

import UIKit
import SendbirdLiveSDK

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage()}
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }

    func resize(with targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scale = max(widthRatio, heightRatio)

        let scaledImageSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }

        return scaledImage
    }
}

extension LiveEvent {
    func getRandomCoverColor() -> UIColor {
        let seed = liveEventId.hash
        srand48(seed)
        let random = UInt64(5 * drand48())
        switch random {
        case 0: return UIColor(red: 89/255, green: 89/255, blue: 211/255, alpha: 1.0)
        case 1: return UIColor(red: 2/255, green: 125/255, blue: 105/255, alpha: 1.0)
        case 2: return UIColor(red: 132/255, green: 75/255, blue: 8/255, alpha: 1.0)
        case 3: return UIColor(red: 75/255, green: 17/255, blue: 161/255, alpha: 1.0)
        default: return UIColor(red: 128/255, green: 18/255, blue: 179/255, alpha: 1.0)
        }
    }
}
