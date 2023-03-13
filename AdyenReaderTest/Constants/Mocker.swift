//
//  Constant.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct Mocker {
    
    static var orderRequest: [String : Any] {
        switch LocalStorage.environment {
        case .allburov:
            return orderRequestAllburov
        case .staging:
            return orderRequestStaging
        case .production:
            return orderRequestProductin
        }
    }
    
    static
    let orderRequestAllburov = [
        "reward_uuids" : [

        ],
        "tips_type" : "%",
        "tips" : 25,
        "finished" : true,
        "lines" : [
          [
            "quantity" : 1,
            "instructions" : "",
            "modifiers" : [

            ],
            "item_id" : "2",
            "as_upsell" : false
          ]
        ],
        "number_of_vouchers" : 0,
        "order_for" : "FOR HERE",
        "source" : 0,
        "customer" : [
          "name" : "Ios User Test",
          "phone" : "1112223344"
        ],
        "business_uuid" : "1a0fda12-b413-b0cc-a5d4-ed5293a91671",
        "order_number" : 33
      ] as [String : Any]
    
    
    static
    let orderRequestStaging = [
        "reward_uuids" : [

        ],
        "tips" : 25,
        "business_uuid" : "fab5393a-9467-439c-9bce-6e056e2f6fd9",
        "number_of_vouchers" : 0,
        "order_for" : "FOR HERE",
        "lines" : [
          [
            "quantity" : 1,
            "instructions" : "",
            "modifiers" : [

            ],
            "item_id" : "16",
            "as_upsell" : false
          ]
        ],
        "order_number" : 34,
        "customer" : [
          "phone" : "1112223344",
          "mail" : "inna@getrevi.com",
          "name" : "Maxim",
          "uuid" : "85fdf873-51df-4f54-98d6-78b9de02734c"
        ],
        "tips_type" : "%",
        "source" : 0,
        "finished" : true
    ] as [String : Any]
    
    static let orderRequestProductin: [String: Any] = [
        "reward_uuids" : [

        ],
        "tips" : 25,
        "customer" : [
          "name" : "Max",
          "phone" : "1112223344",
          "uuid" : "7ce8b097-0b46-4213-9d5b-fd762b9e91e7"
        ],
        "number_of_vouchers" : 0,
        "tips_type" : "%",
        "lines" : [
          [
            "quantity" : 1,
            "instructions" : "",
            "modifiers" : [
              [
                "id" : 64071,
                "quantity" : 1
              ]
            ],
            "item_id" : "36211",
            "as_upsell" : false
          ]
        ],
        "order_for" : "FOR HERE",
        "order_number" : 35,
        "source" : 0,
        "finished" : true,
        "business_uuid" : "1a0fda12-b413-b0cc-a5d4-ed5293a91671"
      ]
}
