//
//  Restaurnat.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation


class Restaurant: Codable {
    var name: String?
    var id2: String?
    var uuid: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id2 = "id2"
        case uuid = "uuid"
    }
}
