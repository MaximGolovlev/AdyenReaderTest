//
//  UIView+Ext.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 18.11.2020.
//  Copyright © 2020 Christopher Sukhram. All rights reserved.
//

import UIKit

public extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
    
    func removeArrangedSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

