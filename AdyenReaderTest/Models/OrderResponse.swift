//
//  OrderResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct OrderResponse: Codable {
    var order: Order
    
    enum CodingKeys: String, CodingKey {
        case order
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        order = try container.decode(Order.self, forKey: .order)
    }
}

struct Order: Codable {
    var uuid: String?
    
    enum CodingKeys: String, CodingKey {
      case uuid
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String?.self, forKey: .uuid)
    }
}
