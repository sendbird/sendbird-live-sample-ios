//
//  PaddingLabel.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/04.
//

import UIKit

public class PaddingLabel: UILabel {
    enum InsetType {
        case top
        case bottom
        case leading
        case trailing
        case vertical
        case horizontal
        case all
    }

@IBInspectable public private(set) var top: CGFloat
@IBInspectable public private(set) var bottom: CGFloat
@IBInspectable public private(set) var leading: CGFloat
@IBInspectable public private(set) var trailing: CGFloat

    public convenience init(_ all: CGFloat) {
        self.init(all, all, all, all)
    }

    public convenience init(_ vertical: CGFloat, _ horizontal: CGFloat) {
        self.init(vertical, vertical, horizontal, horizontal)
    }

    public init(_ top: CGFloat = 0, _ bottom: CGFloat = 0, _ leading: CGFloat = 0, _ trailing: CGFloat = 0) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing

        super.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        self.top = 0
        self.bottom = 0
        self.leading = 0
        self.trailing = 0

        super.init(coder: coder)
    }

    public override func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        super.drawText(in: rect.inset(by: padding))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let horizontal = leading + trailing
        let vertical = top + bottom
        return CGSize(width: size.width + horizontal, height: size.height + vertical)
    }
}
