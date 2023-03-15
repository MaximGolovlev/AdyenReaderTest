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
    var paymentStatus: String?
    var totalCents: Int
    
    var total: Float {
        return Float(totalCents) / 100
    }
    
    var totalString: String? {
        let string = NumberFormatter.currency.string(for: total)
        return string
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case paymentStatus = "payment_status"
        case totalCents = "total_cents"
    }
    
    init(uuid: String?, paymentStatus: String?, total: Int) {
        self.uuid = uuid
        self.paymentStatus = paymentStatus
        self.totalCents = total
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String?.self, forKey: .uuid)
        paymentStatus = try container.decode(String?.self, forKey: .paymentStatus)
        totalCents = try container.decode(Int.self, forKey: .totalCents)
    }
}
