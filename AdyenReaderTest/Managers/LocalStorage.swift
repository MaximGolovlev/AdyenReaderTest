//
//  LocalStorage.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation


class LocalStorage {
    
    static var orderUUID: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "orderUUID")
        }
        get {
            return UserDefaults.standard.string(forKey: "orderUUID")
        }
    }
    
    static var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
    }
    
    static var poiID: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "poiID")
        }
        get {
            return UserDefaults.standard.string(forKey: "poiID")
        }
    }
    
}
