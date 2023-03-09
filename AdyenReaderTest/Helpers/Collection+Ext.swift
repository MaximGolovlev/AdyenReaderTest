//
//  Collection+Ext.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 04.02.2021.
//  Copyright © 2021 ZYRL. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
