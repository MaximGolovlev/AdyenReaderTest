//
//  MenuResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 28.03.2023.
//

import Foundation


struct MenuResponse: Codable {
    var menuItems = [MenuItem]()
    
    enum CodingKeys: String, CodingKey {
        case menuItems = "menu"
    }
    
    struct MenuItemIdKey : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let container = try? container.nestedContainer(keyedBy: MenuItemIdKey.self, forKey: .menuItems) {
            for key in container.allKeys {
                guard key.stringValue != "null" else { continue }
                let menuItem = try container.decode(MenuItem.self, forKey: key)
                menuItems.append(menuItem)
            }
        }
    }
}
