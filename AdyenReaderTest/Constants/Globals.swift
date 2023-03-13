//
//  Globals.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation


struct Globals {
    
    static var isLoggedIn: Bool {
        let baseUrl = LocalStorage.environment.url
        let token = LocalStorage.token
        let location = LocalStorage.restaurant?.name
        
        return !token.isEmptyOrNil && !baseUrl.isEmpty && !location.isEmptyOrNil
    }
    
}
