//
//  ReactionAnimator.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/03/17.
//

import UIKit

struct ReactionAnimationOptions {
    let initialPosition: CGPoint
    let randomXOffet: CGFloat

    let superviewSize: CGSize
    let duration: TimeInterval

    let size: CGSize
    let image: UIImage

    let colorSet: [UIColor]
}

class ReactionAnimator {
    var view: UIView

    var animationQueue: DispatchQueue = DispatchQueue(label: "com.sendbird.live.reactionAnimator.\(UUID().uuidString)")

    init(view: UIView) {
        self.view = view
    }

    func animate(count: Int, options: ReactionAnimationOptions) {
        let min = [count, 10].min() ?? 1
        let delay = 1 / Double(min)
        for index in 0..<min {
            self.animationQueue.asyncAfter(deadline: .now() + Double(delay * Double(index))) {
                self.performAnimation(options: options)
            }
        }
    }

    func performAnimation(options: ReactionAnimationOptions) {
        animate(options: options)
    }

    var count = 0
    private func animate(options: ReactionAnimationOptions) {
        count += 1
        DispatchQueue.main.async {
            let randomColor = options.colorSet.randomElement()
            let image = options.image.sbu_with(tintColor: randomColor)
            let reactionImage = UIImageView(image: image)
            reactionImage.alpha = 0

            let size = CGSize(width: options.size.width / 2, height: options.size.height / 2)

            self.view.addSubview(reactionImage)

            // set random x position within specified offset of horizontal center of screen
            let centerX = options.initialPosition.x

            let randomX = CGFloat(arc4random_uniform(UInt32(options.randomXOffet))) * (arc4random_uniform(2) == 0 ? -1 : 1)
            let startX = centerX + randomX
            reactionImage.frame = CGRect(x: startX - options.size.width / 2, y: options.initialPosition.y, width: size.width, height: size.height)

            let firstX = options.size.width / 2
            let secondX = options.superviewSize.width - options.size.width / 2
            // animate the heart after a delay
            UIView.animateKeyframes(withDuration: options.duration, delay: 0, options: [.calculationModeCubic], animations: {
                let xRepeatCount = Int.random(in: 1...4)

                for i in 0..<xRepeatCount {
                    // Move left and right x number of times while going up
                    UIView.addKeyframe(withRelativeStartTime: Double(i)/Double(xRepeatCount), relativeDuration: 1/Double(xRepeatCount), animations: {
                        reactionImage.center.x = (i % 2 == (randomX < 0 ? 0 : 1)) ? firstX : secondX
                        reactionImage.center.y -= options.superviewSize.height / CGFloat(xRepeatCount)
                    })
                }

                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/4, animations: {
                    reactionImage.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    reactionImage.alpha = 1
                })

                UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 3/4, animations: {
                    reactionImage.alpha = 0
                })

            }, completion: { _ in
                reactionImage.removeFromSuperview()
            })
        }
    }
}
