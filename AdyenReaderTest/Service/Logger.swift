//
//  Logger.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 20.03.2021.
//  Copyright © 2021 ZYRL. All rights reserved.
//

import Foundation

class Logger {
    
    static func request(request: String, headers: [String: Any] = [:], params: [String: Any?]) {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("\nHTTP request: \(request)\nHeaders: \(headers)\nParams: \(jsonString)\n")
        }
    }
    
    static func response(request: String, data: Data?) {
        guard let data = data else { return }
        if let jsonString = String(data: data, encoding: .utf8) {
            print("\nHTTP response: \(request)\nParams: \(jsonString)\n")
        }
    }
}

