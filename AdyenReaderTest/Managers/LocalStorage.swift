//
//  LocalStorage.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation


class LocalStorage {
    
    static var order: Order? {
        set(order) {
            UserDefaults.standard.set(order?.uuid, forKey: "order.UUID")
            UserDefaults.standard.set(order?.paymentStatus, forKey: "order.paymentStatus")
        }
        get {
            guard let uuid = UserDefaults.standard.string(forKey: "order.UUID"),
                  let paymentStatus = UserDefaults.standard.string(forKey: "order.paymentStatus") else {
                return nil
            }
            
            return Order(uuid: uuid, paymentStatus: paymentStatus)
        }
    }
    
    static var token: String? {
        set {
            switch environment {
            case .allburov:
                UserDefaults.standard.set(newValue, forKey: "allburovToken")
            case .staging:
                UserDefaults.standard.set(newValue, forKey: "stagingToken")
            case .production:
                UserDefaults.standard.set(newValue, forKey: "productionToken")
            }
        }
        get {
            switch environment {
            case .allburov:
                return UserDefaults.standard.string(forKey: "allburovToken")
            case .staging:
                return UserDefaults.standard.string(forKey: "stagingToken")
            case .production:
                return UserDefaults.standard.string(forKey: "productionToken")
            }
        }
    }
    
    static var terminalModel: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "terminalModel")
        }
        get {
            return UserDefaults.standard.string(forKey: "terminalModel")
        }
    }
    
    static var terminalSerial: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "terminalSerial")
        }
        get {
            return UserDefaults.standard.string(forKey: "terminalSerial")
        }
    }
    
    static var environment: Environment {
        get {
            guard let environment = UserDefaults.standard.value(forKey: "Environment") as? String,
                    let obj = Environment(rawValue: environment) else {
                return .allburov
            }
            return obj
        }
        set(environment) {
            UserDefaults.standard.set(environment.rawValue, forKey: "Environment")
        }
    }
    
    static var restaurant: Restaurant? {
        set(restaurant) {
            switch environment {
            case .allburov:
                UserDefaults.standard.set(restaurant?.id2, forKey: "Restaurant.id.allburov")
                UserDefaults.standard.set(restaurant?.name, forKey: "Restaurant.name.allburov")
            case .staging:
                UserDefaults.standard.set(restaurant?.id2, forKey: "Restaurant.id.staging")
                UserDefaults.standard.set(restaurant?.name, forKey: "Restaurant.name.staging")
            case .production:
                UserDefaults.standard.set(restaurant?.id2, forKey: "Restaurant.id.production")
                UserDefaults.standard.set(restaurant?.name, forKey: "Restaurant.name.production")
            }
        }
        get {
            
            switch environment {
            case .allburov:
                guard let id2 = UserDefaults.standard.value(forKey: "Restaurant.id.allburov") as? String,
                      let name = UserDefaults.standard.value(forKey: "Restaurant.name.allburov") as? String else { return nil }
                return Restaurant(name: name, id2: id2)
            case .staging:
                guard let id2 = UserDefaults.standard.value(forKey: "Restaurant.id.staging") as? String,
                      let name = UserDefaults.standard.value(forKey: "Restaurant.name.staging") as? String else { return nil }
                return Restaurant(name: name, id2: id2)
            case .production:
                guard let id2 = UserDefaults.standard.value(forKey: "Restaurant.id.production") as? String,
                      let name = UserDefaults.standard.value(forKey: "Restaurant.name.production") as? String else { return nil }
                return Restaurant(name: name, id2: id2)
            }
        }
    }
    
}
