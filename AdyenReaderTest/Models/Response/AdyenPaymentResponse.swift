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
    let paymentReceipt: [PaymentReceipt]?
    
    enum CodingKeys: String, CodingKey {
        case poiData = "POIData"
        case saleData = "SaleData"
        case paymentResult = "PaymentResult"
        case adyenResponse = "Response"
        case paymentReceipt = "PaymentReceipt"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        poiData = try container.decode(POIData.self, forKey: .poiData)
        saleData = try container.decode(SaleData.self, forKey: .saleData)
        paymentResult = try container.decode(PaymentResult.self, forKey: .paymentResult)
        adyenResponse = try container.decode(AdyenResponse.self, forKey: .adyenResponse)
        paymentReceipt = try? container.decode([PaymentReceipt].self, forKey: .paymentReceipt)
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
    let onlineFlag: Bool?
    let paymentInstrumentData: PaymentInstrumentData
    let amountsResp: AmountsResp?
    
    enum CodingKeys: String, CodingKey {
        case paymentAcquirerData = "PaymentAcquirerData"
        case onlineFlag = "OnlineFlag"
        case paymentInstrumentData = "PaymentInstrumentData"
        case amountsResp = "AmountsResp"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentAcquirerData = try container.decode(PaymentAcquirerData.self, forKey: .paymentAcquirerData)
        onlineFlag = try? container.decode(Bool.self, forKey: .onlineFlag)
        paymentInstrumentData = try container.decode(PaymentInstrumentData.self, forKey: .paymentInstrumentData)
        amountsResp = try? container.decode(AmountsResp.self, forKey: .amountsResp)
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
    
    let maskedPan: String?
    let sensitiveCardData: SensitiveCardData?
    let entryMode: [String]?
    let paymentBrand: String?
    
    enum CodingKeys: String, CodingKey {
        case maskedPan = "MaskedPan"
        case sensitiveCardData = "SensitiveCardData"
        case entryMode = "EntryMode"
        case paymentBrand = "PaymentBrand"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        maskedPan = try? container.decode(String.self, forKey: .maskedPan)
        sensitiveCardData = try? container.decode(SensitiveCardData.self, forKey: .sensitiveCardData)
        entryMode = try? container.decode([String].self, forKey: .entryMode)
        paymentBrand = try? container.decode(String.self, forKey: .paymentBrand)
    }
}

struct SensitiveCardData: Codable {
    
    let expiryDate: String
    
    enum CodingKeys: String, CodingKey {
        case expiryDate = "ExpiryDate"
    }
}

struct PaymentAcquirerData: Codable {
    
    let approvalCode: String?
    let acquirerTransactionID: AcquirerTransactionID?
    let acquirerPOIID: String
    let merchantID: String
    
    enum CodingKeys: String, CodingKey {
        case approvalCode = "ApprovalCode"
        case acquirerTransactionID = "AcquirerTransactionID"
        case acquirerPOIID = "AcquirerPOIID"
        case merchantID = "MerchantID"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        approvalCode = try? container.decode(String.self, forKey: .approvalCode)
        acquirerTransactionID = try? container.decode(AcquirerTransactionID.self, forKey: .acquirerTransactionID)
        acquirerPOIID = try container.decode(String.self, forKey: .acquirerPOIID)
        merchantID = try container.decode(String.self, forKey: .merchantID)
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
