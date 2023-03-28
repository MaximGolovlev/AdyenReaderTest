//
//  TerminalPaymentResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import Foundation


struct TerminalPaymentResponse: Codable {
    
    var status: String
    var serviceId: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case serviceId = "ServiceID"
    }
    
}
