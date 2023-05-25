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
    
    let messageHeader: PaymentMessageHeader
    let paymentRequest: PaymentRequest
    
    enum CodingKeys: String, CodingKey {
        case messageHeader = "MessageHeader"
        case paymentRequest = "PaymentRequest"
    }
    
}

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
    
    let saleData: SaleData
    let paymentTransaction: PaymentTransaction
    
    enum CodingKeys: String, CodingKey {
        case saleData = "SaleData"
        case paymentTransaction = "PaymentTransaction"
    }
}

struct SaleData: Codable {
    let saleTransactionID: SaleTransactionID
    let saleToAcquirerData: String?
    
    enum CodingKeys: String, CodingKey {
        case saleTransactionID = "SaleTransactionID"
        case saleToAcquirerData = "SaleToAcquirerData"
    }
}

struct SaleTransactionID: Codable {
    let transactionID: String
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "TransactionID"
        case timeStamp = "TimeStamp"
    }
}

struct PaymentTransaction: Codable {
    
    let amountsReq: AmountsReq
    
    enum CodingKeys: String, CodingKey {
        case amountsReq = "AmountsReq"
    }
}

struct AmountsReq: Codable {
    
    let currency: String
    let requestedAmount: Decimal
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case requestedAmount = "RequestedAmount"
    }
}

