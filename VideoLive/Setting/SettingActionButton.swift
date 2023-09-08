//
//  SettingActionView.swift
//  QuickStart
//
//  Created by Ernest Hong on 2022/09/30.
//

import UIKit

final class SettingActionButton: UnderLineView {
    
    private let didTouchAction: () -> Void
    
    private lazy var infoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "iconInfo"))
        imageView.accessibilityLabel = "info icon"
        return imageView
    }()
    
    private lazy var actionTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Application information"
        return titleLabel
    }()
    
    private lazy var iconChevronRightView: UIImageView = {
        let iconChevronRightView = UIImageView(image: UIImage(named: "iconChevronRight"))
        iconChevronRightView.accessibilityLabel = "info right arrow"
        return iconChevronRightView
    }()
    
    init(didTouchAction: @escaping () -> Void) {
        self.didTouchAction = didTouchAction
        super.init(frame: .zero)
        
        addSubview(infoImageView)
        infoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoImageView.widthAnchor.constraint(equalToConstant: 24),
            infoImageView.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        addSubview(actionTitleLabel)
        actionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionTitleLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 16),
            actionTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            actionTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        
        addSubview(iconChevronRightView)
        iconChevronRightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconChevronRightView.leadingAnchor.constraint(equalTo: actionTitleLabel.trailingAnchor, constant: 16),
            iconChevronRightView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            iconChevronRightView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconChevronRightView.widthAnchor.constraint(equalToConstant: 24),
            iconChevronRightView.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTouch))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTouch() {
        didTouchAction()
    }
}
