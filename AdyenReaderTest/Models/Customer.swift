//
//  Customer.swift
//  AdyenReaderTest
//
//  Created by Maxim on 28.03.2023.
//

import Foundation


struct Customer: Codable {
    
    var name: String
    var phone: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case phone = "phone"
    }
}
