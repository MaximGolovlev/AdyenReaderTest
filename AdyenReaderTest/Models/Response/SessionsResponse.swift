//
//  SessionsResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct SessionsResponse: Codable {
    let id: String
    let installationId: String
    let merchantAccount: String
    let sdkData: String
    let store: String

    enum CodingKeys: String, CodingKey {
        case id
        case installationId
        case merchantAccount
        case sdkData
        case store
    }
}
