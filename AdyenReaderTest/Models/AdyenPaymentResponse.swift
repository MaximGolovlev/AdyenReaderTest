//
//  AdyenPaymentResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 10.03.2023.
//

import Foundation

struct AdyenPaymentResponse: Codable {
    
    let response: SaleToPOIResponse
    
    enum CodingKeys: String, CodingKey {
        case response = "SaleToPOIResponse"
    }
    
}

struct SaleToPOIResponse: Codable {
    
    let messageHeader: PaymentMessageHeader
    let paymentResponse: PaymentResponse
    
    enum CodingKeys: String, CodingKey {
        case messageHeader = "MessageHeader"
        case paymentResponse = "PaymentResponse"
    }
    
}

struct PaymentResponse: Codable {
    
    let poiData: POIData
    let saleData: SaleData
    let paymentResult: PaymentResult
    let adyenResponse: AdyenResponse
    let paymentReceipt: [PaymentReceipt]
    
    enum CodingKeys: String, CodingKey {
        case poiData = "POIData"
        case saleData = "SaleData"
        case paymentResult = "PaymentResult"
        case adyenResponse = "Response"
        case paymentReceipt = "PaymentReceipt"
    }
}

struct POIData: Codable {
    let poiReconciliationID: String
    let poiTransactionID: POITransactionID
    
    enum CodingKeys: String, CodingKey {
        case poiReconciliationID = "POIReconciliationID"
        case poiTransactionID = "POITransactionID"
    }
}

struct POITransactionID: Codable {
    let transactionID: String
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "TransactionID"
        case timeStamp = "TimeStamp"
    }
}

struct PaymentResult: Codable {
    
    let paymentAcquirerData: PaymentAcquirerData
    let onlineFlag: Bool
    let paymentInstrumentData: PaymentInstrumentData
    let amountsResp: AmountsResp
    
    enum CodingKeys: String, CodingKey {
        case paymentAcquirerData = "PaymentAcquirerData"
        case onlineFlag = "OnlineFlag"
        case paymentInstrumentData = "PaymentInstrumentData"
        case amountsResp = "AmountsResp"
    }
}

struct AmountsResp: Codable {
    
    let currency: String
    let authorizedAmount: String
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case authorizedAmount = "AuthorizedAmount"
    }
}

struct PaymentInstrumentData: Codable {
    
    let cardData: CardData
    let paymentInstrumentType: String
    
    enum CodingKeys: String, CodingKey {
        case cardData = "CardData"
        case paymentInstrumentType = "PaymentInstrumentType"
    }
    
}

struct CardData: Codable {
    
    let maskedPan: String
    let sensitiveCardData: SensitiveCardData
    let entryMode: [String]
    let paymentBrand: String
    
    enum CodingKeys: String, CodingKey {
        case maskedPan = "MaskedPan"
        case sensitiveCardData = "SensitiveCardData"
        case entryMode = "EntryMode"
        case paymentBrand = "PaymentBrand"
    }
}

struct SensitiveCardData: Codable {
    
    let expiryDate: String
    
    enum CodingKeys: String, CodingKey {
        case expiryDate = "ExpiryDate"
    }
}

struct PaymentAcquirerData: Codable {
    
    let approvalCode: String
    let acquirerTransactionID: AcquirerTransactionID
    let acquirerPOIID: String
    let merchantID: String
    
    enum CodingKeys: String, CodingKey {
        case approvalCode = "ApprovalCode"
        case acquirerTransactionID = "AcquirerTransactionID"
        case acquirerPOIID = "AcquirerPOIID"
        case merchantID = "MerchantID"
    }
    
}

struct AcquirerTransactionID: Codable {
    let transactionID: String
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case transactionID = "TransactionID"
        case timeStamp = "TimeStamp"
    }
}

struct AdyenResponse: Codable {
    
    let additionalResponse: String
    let result: String
    let errorCondition: String
    
    enum CodingKeys: String, CodingKey {
        case additionalResponse = "AdditionalResponse"
        case result = "Result"
        case errorCondition = "ErrorCondition"
    }
}

struct PaymentReceipt: Codable {
    
    let documentQualifier: String
    let outputContent: OutputContent
    let requiredSignatureFlag: Bool
    
    enum CodingKeys: String, CodingKey {
        case documentQualifier = "DocumentQualifier"
        case outputContent = "OutputContent"
        case requiredSignatureFlag = "RequiredSignatureFlag"
    }
}

struct OutputContent: Codable {
    
    let outputFormat: String
    let outputText: [OutputText]
    
    enum CodingKeys: String, CodingKey {
        case outputFormat = "OutputFormat"
        case outputText = "OutputText"
    }

}

struct OutputText: Codable {
    
    let text: String
    let characterStyle: String?
    let endOfLineFlag: Bool
    
    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case characterStyle = "CharacterStyle"
        case endOfLineFlag = "EndOfLineFlag"
    }
    
}
