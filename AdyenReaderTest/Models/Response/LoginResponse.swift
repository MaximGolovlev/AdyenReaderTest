//
//  LoginResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct LoginResponse: Codable {
    
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case token
    }
                   
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        token = try? values.decode(String?.self, forKey: .token)
    }
}
