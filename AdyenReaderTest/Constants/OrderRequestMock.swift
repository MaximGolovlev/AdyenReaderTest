//
//  Constant.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

enum OrderRequestType: String, CaseIterable {
    case regular
    case authorised //100
    case declined //123
    case notEnoughBalance //124
    case blockedCard //125
    case cardExpired //126
    case invalidOnlinePIN // 134
    
    var title: String {
        switch self {
        case .regular:
            return "Regular"
        case .authorised:
            return "Authorised (100)"
        case .declined:
            return "Declined online (123)"
        case .notEnoughBalance:
            return "Not enough balance (124)"
        case .blockedCard:
            return "Card blocked (125)"
        case .cardExpired:
            return "Card expired (126)"
        case .invalidOnlinePIN:
            return "Invalid online PIN (134)"
        }
    }
}

struct OrderRequestMock {
    
    var tips: Int {
        let type = LocalStorage.orderRequestType
        switch type {
        case .regular:
            return 10
        default:
            return 0
        }
    }
    
    var businessUUID: String {
        LocalStorage.restaurant?.uuid ?? ""
    }
    
    var orderLines: [[String: Any]] {
        LocalStorage.menuItems.compactMap({ $0.toRequestLine })
    }
    
    var orderNumber: Int {
        34
    }
    
    var customer: [String: Any] {
        switch LocalStorage.environment {
        case .allburov:
            return Customer(name: "Ios User Test", phone: "1112223344").dictionary ?? [:]
        case .staging:
            return Customer(name: "Ios User Test", phone: "1112223344").dictionary ?? [:]
        case .production:
            return Customer(name: "Ios User Test", phone: "1112223344").dictionary ?? [:]
        }
    }
    
    var tipsType: String {
        "$"
    }
    
    var source: Int {
        0
    }
    
    var finished: Bool {
        true
    }
    
    var orderRequest: [String: Any] {
        ["reward_uuids" : [],
        "tips" : tips,
        "tips_type" : tipsType,
        "business_uuid" : businessUUID,
        "number_of_vouchers" : 0,
        "order_for" : "FOR HERE",
        "lines" : orderLines,
        "order_number" : orderNumber,
        "source" : source,
        "finished" : finished,
        "customer" : customer
        ] as [String : Any]
    }
}
