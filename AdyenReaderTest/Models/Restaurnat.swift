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
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case id2 = "id2"
    }
    
    init(name: String?, id2: String?) {
        self.name = name
        self.id2 = id2
    }
}
