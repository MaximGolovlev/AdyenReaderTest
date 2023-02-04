//
//  SessionSetupRequest.swift
//  AdyenReaderTest
//
//  Created by Maxim on 12.09.2022.
//

import Foundation
import Adyen
import AdyenComponents

struct Amount: Codable {
    let value: Double
    let currency: String
    let localeIdentifier: String?
}

struct SessionSetupRequest: Codable {
    
    static var testRequest: SessionSetupRequest {
        return SessionSetupRequest(countryCode: "NL",
                                   shopperEmail: "checkoutShopperiOS@example.org",
                                   shopperReference: "iOS Checkout Shopper",
                                   merchantAccount: "ReviAccount918POS",
                                   amount: Amount(value: 17408, currency: "EUR", localeIdentifier: nil),
                                   returnUrl:  "ui-host://",
                                   reference: "Test Order Reference - iOS UIHost",
                                   additionalData: ["allow3DS2": true],
                                   lineItems: [["description": "Socks",
                                                "quantity": "2",
                                                "amountIncludingTax": "300",
                                                "amountExcludingTax": "248",
                                                "taxAmount": "52",
                                                "id": "Item #2"]])
    }
    
    let countryCode: String
    let shopperLocale: String = Locale.current.identifier
    let shopperEmail: String
    let shopperReference: String
    let merchantAccount: String
    let amount: Amount
    let returnUrl: String
    let reference: String
    let channel: String = "iOS"
    let additionalData: [String : Bool]
    let lineItems: [[String : String]]
    
    enum CodingKeys: CodingKey {
        case countryCode
        case shopperLocale
        case shopperEmail
        case shopperReference
        case merchantAccount
        case amount
        case returnUrl
        case reference
        case channel
        case additionalData
        case lineItems
    }
    
}

struct SessionSetupResponse: Codable {
    
    let sessionData: String
    let sessionId: String
    
    internal enum CodingKeys: String, CodingKey {
        case sessionData
        case sessionId = "id"
    }
}
