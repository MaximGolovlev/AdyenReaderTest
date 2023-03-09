//
//  Constant.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct Mocker {
    
    static
    let orderRequestParams = [
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
}
