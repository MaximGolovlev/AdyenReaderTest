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
            if let encoded = try? JSONEncoder().encode(order){
                UserDefaults.standard.set(encoded, forKey: "selectedOrder")
            }
        }
        get {
            if let data = UserDefaults.standard.value(forKey: "selectedOrder") as? Data, let objectDecoded = try? JSONDecoder().decode(Order.self, from: data) as Order {
                return objectDecoded
            }
            return nil
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
            if let encoded = try? JSONEncoder().encode(restaurant){
                UserDefaults.standard.set(encoded, forKey: "selectedRestaurant")
            }
        }
        get {
            if let data = UserDefaults.standard.value(forKey: "selectedRestaurant") as? Data, let objectDecoded = try? JSONDecoder().decode(Restaurant.self, from: data) as Restaurant {
                return objectDecoded
            }
            return nil
        }
    }
    
    static var menuItems: [MenuItem] {
        set(menuItem) {
            if let encoded = try? JSONEncoder().encode(menuItem){
                UserDefaults.standard.set(encoded, forKey: "menuItem_objs")
            }
        }
        get {
            if let objects = UserDefaults.standard.value(forKey: "menuItem_objs") as? Data, let objectsDecoded = try? JSONDecoder().decode(Array.self, from: objects) as [MenuItem] {
                return objectsDecoded
            }
            return []
        }
    }
    
    static var orderRequestType: OrderRequestType {
        get {
            guard let type = UserDefaults.standard.value(forKey: "OrderRequestType") as? String,
                  let obj = OrderRequestType(rawValue: type) else {
                return .regular
            }
            return obj
        }
        set(type) {
            UserDefaults.standard.set(type.rawValue, forKey: "OrderRequestType")
        }
    }
}
