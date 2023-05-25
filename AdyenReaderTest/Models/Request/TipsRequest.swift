//
//  TipsRequest.swift
//  AdyenReaderTest
//
//  Created by Maxim on 24.05.2023.
//

import Foundation

struct TipsRequest: Codable {
    let tipCents: Int
    let type: TipsType
    
    var nameString: String? {
        NumberFormatter.currency.string(for: Float(tipCents)/100)
    }
    
    enum CodingKeys: String, CodingKey {
        case tipCents = "tips"
        case type = "tips_type"
    }
    
    init(tipCents: Int, type: TipsType) {
        self.tipCents = tipCents
        self.type = type
    }
}

enum TipsType: String, Codable, Equatable {
    case dollars = "$"
    case percent = "%"
}
