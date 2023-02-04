//
//  PaymentRequest.swift
//  AdyenReaderTest
//
//  Created by Maxim on 12.09.2022.
//

import Foundation
import TerminalAPIKit

struct SaleRequestAdapter: Codable {
    let messageHeader: MessageHeaderAdapter
    let paymentRequest: PaymentRequestAdapter
    
    enum CodingKeys: String, CodingKey {
        case messageHeader = "MessageHeader"
        case paymentRequest = "PaymentRequest"
    }
    
    enum MainKey: String, CodingKey {
        case saleToPOIRequest = "SaleToPOIRequest"
    }
    
    init(from decoder: Decoder) throws {
        let mainContainer = try decoder.container(keyedBy: MainKey.self)
        let nestedContainer = try mainContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .saleToPOIRequest)
        
        messageHeader = try nestedContainer.decode(MessageHeaderAdapter.self, forKey: .messageHeader)
        paymentRequest = try nestedContainer.decode(PaymentRequestAdapter.self, forKey: .paymentRequest)
    }
    
    var toTerminalRequest: Message<PaymentRequest>? {
        guard let header = messageHeader.toHeader else { return nil }
        let request = paymentRequest.toRequest
        return Message(header: header, body: request)
    }
    
}

struct MessageHeaderAdapter: Codable {
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
    
    var toHeader: MessageHeader? {
        
        guard let messageClass = MessageClass(rawValue: messageClass),
              let messageCategory = MessageCategory(rawValue: messageCategory),
              let messageType = MessageType(rawValue: messageType) else { return nil }
        
        return MessageHeader(protocolVersion: protocolVersion,
                             messageClass: messageClass,
                             messageCategory: messageCategory,
                             messageType: messageType,
                             serviceIdentifier: serviceID,
                             deviceIdentifier: nil,
                             saleIdentifier: saleID,
                             poiIdentifier: POIID)
    }
}

struct PaymentRequestAdapter: Codable {
    let saleData: SaleDataAdapter
    let paymentTransaction: PaymentTransactionAdapter
    
    enum CodingKeys: String, CodingKey {
        case saleData = "SaleData"
        case paymentTransaction = "PaymentTransaction"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        saleData = try container.decode(SaleDataAdapter.self, forKey: .saleData)
        paymentTransaction = try container.decode(PaymentTransactionAdapter.self, forKey: .paymentTransaction)
    }
    
    var toRequest: PaymentRequest {
        let saleData = saleData.toSaleData
        let amount = Amounts(currency: paymentTransaction.amountsReq.currency, requestedAmount: paymentTransaction.amountsReq.requestedAmount)
        let paymentTransaction = PaymentTransaction(amounts: amount)
        let paymentRequest = PaymentRequest(saleData: saleData, paymentTransaction: paymentTransaction)
        return paymentRequest
    }
}

struct SaleDataAdapter: Codable {
    let saleTransactionID: SaleTransactionIDAdapter
    
    enum CodingKeys: String, CodingKey {
        case saleTransactionID = "SaleTransactionID"
    }
    
    var toSaleData: SaleData {
        return SaleData(saleTransactionIdentifier: saleTransactionID.toTransactionID)
    }
}

struct SaleTransactionIDAdapter: Codable {
    let transactionID: String
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "TransactionID"
        case timeStamp = "TimeStamp"
    }
    
    var toTransactionID: TransactionIdentifier {
        let date = timeStamp.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ") ?? Date()
        return TransactionIdentifier(transactionIdentifier: transactionID, date: date)
    }
}

struct PaymentTransactionAdapter: Codable {
    let amountsReq: AmountsReqAdapter
    
    enum CodingKeys: String, CodingKey {
        case amountsReq = "AmountsReq"
    }
}

struct AmountsReqAdapter: Codable {
    let currency: String
    let requestedAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case requestedAmount = "RequestedAmount"
    }
}

