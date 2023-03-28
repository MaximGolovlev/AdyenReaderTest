//
//  MenuItem.swift
//  AdyenReaderTest
//
//  Created by Maxim on 28.03.2023.
//

import Foundation


struct MenuItem: Codable {
    
    var id: String
    var name: String
    var price: String
    var isUpsell: Bool
    var quantity: Int
    
    var description: String {
        "\(quantity) (\(name)) \(NumberFormatter.currency.string(for: Double(price)) ?? price)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case price = "price"
        case isUpsell = "isUpsell"
        case quantity = "quantity"
    }
    
    var toRequestLine: [String: Any] {
        ["quantity" : quantity,
        "instructions" : "",
        "modifiers" : [],
        "item_id" : id,
        "as_upsell" : isUpsell]
    }
    
    init(id: Int, quantity: Int, name: String, price: String) {
        self.id = "\(id)"
        self.quantity = quantity
        self.price = price
        self.name = name
        self.isUpsell = false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let stringId = try? container.decode(String?.self, forKey: .id)
        let intId = try? container.decode(Int?.self, forKey: .id)
        id = stringId ?? intId.map({ String($0) }) ?? "-1"
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(String.self, forKey: .price)
        isUpsell = try container.decode(Bool.self, forKey: .isUpsell)
        quantity = (try? container.decode(Int.self, forKey: .quantity)) ?? 1
    }
}
