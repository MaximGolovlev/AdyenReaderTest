//
//  AdyenPaymentRequest.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation


struct AdyenPaymentRequest: Codable {
    
    let request: SaleToPOIRequest
    
    enum CodingKeys: String, CodingKey {
        case request = "SaleToPOIRequest"
    }
}

struct SaleToPOIRequest: Codable {
    
    struct PaymentMessageHeader: Codable {
        let protocolVersion: String
        let messageClass: String
        let messageCategory: String
        let messageType: String
        let saleID: String
        let serviceID: String
        let POIID: String
        
        enum CodingKeys: String, CodingKey {
            case protocolVersion = "ProtocolVersion"
            case messageClass = "MessageClass"
            case messageCategory = "MessageCategory"
            case messageType = "MessageType"
            case saleID = "SaleID"
            case serviceID = "ServiceID"
            case POIID
        }
    }
    
    
    struct PaymentRequest: Codable {
        
    }

    
    let messageHeader: PaymentMessageHeader
    let paymentRequest: PaymentRequest
    
    enum CodingKeys: String, CodingKey {
        case messageHeader = "MessageHeader"
        case paymentRequest = "PaymentRequest"
    }
    
}
