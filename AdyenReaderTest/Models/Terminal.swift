//
//  Terminal.swift
//  AdyenReaderTest
//
//  Created by Maxim on 15.03.2023.
//

import Foundation


struct Terminal: Codable {
    
    let model: String
    let serial: String
    let time: Double
    
    var poiid: String {
        "\(model)-\(serial)"
    }
}
