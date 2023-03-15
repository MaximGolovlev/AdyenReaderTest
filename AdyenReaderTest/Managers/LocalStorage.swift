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
            UserDefaults.standard.set(order?.totalCents, forKey: "order.total")
        }
        get {
            
            let paymentTotal = UserDefaults.standard.integer(forKey: "order.total")
            
            guard let uuid = UserDefaults.standard.string(forKey: "order.UUID"),
                  let paymentStatus = UserDefaults.standard.string(forKey: "order.paymentStatus") else {
                return nil
            }
            
            return Order(uuid: uuid, paymentStatus: paymentStatus, total: paymentTotal)
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
    
    static var terminals: [Terminal] {
        set(terminals) {
            if let encoded = try? JSONEncoder().encode(terminals){
                UserDefaults.standard.set(encoded, forKey: "terminal_objs")
            }
        }
        get {
            if let objects = UserDefaults.standard.value(forKey: "terminal_objs") as? Data, let objectsDecoded = try? JSONDecoder().decode(Array.self, from: objects) as [Terminal] {
                return objectsDecoded
            }
            return []
        }
    }
    
    static var selectedTerminal: Terminal? {
        set(terminal) {
            if let encoded = try? JSONEncoder().encode(terminal){
                UserDefaults.standard.set(encoded, forKey: "selectedTerminal")
            }
        }
        get {
            if let data = UserDefaults.standard.value(forKey: "selectedTerminal") as? Data, let objectDecoded = try? JSONDecoder().decode(Terminal.self, from: data) as Terminal {
                return objectDecoded
            }
            return nil
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
