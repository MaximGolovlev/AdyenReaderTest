//
//  String.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation

extension Optional where Wrapped == String {

    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }

}
