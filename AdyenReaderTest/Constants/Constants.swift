//
//  Constants.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation

enum Environment: String, CaseIterable {
    case allburov = "AllBurov"
    case staging = "Staging"
    case production = "Production"
    
    var url: String {
        switch self {
        case .staging:
            return "https://zdash-stg.getrevi.com"
        case .production:
            return "https://zdash.zyrl.us"
        case .allburov:
            return "https://zdash-allburov.getrevi.com"
        }
    }
    
    var login: String {
        switch self {
        case .allburov:
            return "admin@admin.com"
        case .staging:
            return "service+stg@getrevi.com"
        case .production:
            return "aakash@zyrl.us"
        }
    }
    
    var password: String {
        switch self {
        case .allburov:
            return "P@ssw0rd"
        case .staging:
            return "thestagingpassword"
        case .production:
            return "IwonttellYOU"
        }
    }
}
