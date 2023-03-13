//
//  AuthResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation

struct AuthResponse: Codable {
    
    var locations = [Restaurant]()
    
    enum CodingKeys: String, CodingKey {
        case locations = "businesses"
    }
                   
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        locations = (try? values.decode([Restaurant]?.self, forKey: .locations)) ?? []
    }
                   
}
