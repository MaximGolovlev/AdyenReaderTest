//
//  APIManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

enum APIManager {
    
    case fetchAdyenSetupToken(setupToken: String, id2: String)
    case payAdyenOrderLocal(orderUUID: String, POIID: String)
    case payAdyenOrderCloud(orderUUID: String, POIID: String)
    case checkAdyenPayment(orderUUID: String)
    
    var baseURL: String {
        return "https://zdash-allburov.getrevi.com"
    }
    
    var token: String {
        return "e2fe23e70b9732bdabb85843f619d5c93284773ef2d4aa72e88dcf1bfa55552a"
    }
    
    var method: String {
        switch self {
        case .fetchAdyenSetupToken:
            return "/api/adyen/terminals/sessions/"
        case .payAdyenOrderLocal(let orderUUID, _):
            return "/api/orders/\(orderUUID)/pay/adyen/payment-request/"
        case .payAdyenOrderCloud(let orderUUID, _):
            return "/api/orders/\(orderUUID)/pay/adyen/via-terminal/"
        case .checkAdyenPayment(let orderUUID):
            return "/api/orders/\(orderUUID)/pay/adyen/check/"
        }
    }
    
    var httpMethod: String {
        switch self {
        case .fetchAdyenSetupToken:
            return "POST"
        case .payAdyenOrderLocal:
            return "GET"
        case .payAdyenOrderCloud:
            return "GET"
        case .checkAdyenPayment:
            return "POST"
        }
    }
    
    var params: [String: String] {
        
        switch self {
        case .fetchAdyenSetupToken(let setupToken, let id2):
            return ["setup_token": setupToken, "id2": id2]
        case .payAdyenOrderLocal:
            return [:]
        case .payAdyenOrderCloud:
            return [:]
        case .checkAdyenPayment:
            return [:]
        }
    }
    
    var query: [(String, String)] {
        switch self {
        case .fetchAdyenSetupToken:
            return []
        case .payAdyenOrderLocal(_, let POIID):
            return [("POIID", POIID)]
        case .payAdyenOrderCloud(_, let POIID):
            return [("POIID", POIID)]
        case .checkAdyenPayment:
            return []
        }
    }
    
    var headers: [String: String] {
        ["Content-Type": "application/json",
         "Authorization": "Token \(token)"]
    }
    
    func makeRequest<T: Codable>() async throws -> T {
        
        let urlPath = baseURL + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            throw NetworkAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        if httpMethod == "POST" {
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            request.httpBody = jsonData
        }
        
        Logger.request(request: url.absoluteString, headers: headers, params: [:])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        Logger.response(request: url.absoluteString, data: data)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode - 200 < 99 {
                
                var sourceData = data
                
                if let responseString = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String {
                    if let stringData = responseString.data(using: .utf8) {
                        sourceData = stringData
                    } else {
                        throw NetworkAuthError.customError("Invalid Response from server")
                    }
                }
                
                let info = try JSONDecoder().decode(T.self, from: sourceData)
                return info
                
            } else {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let detail = json?["detail"] as? String {
                    throw NetworkAuthError.customError("\(detail)")
                } else {
                    let message = json.map({ "\($0)" }) ?? "Empty"
                    throw NetworkAuthError.customError(message)
                }
            }
        } else {
            throw NetworkAuthError.invalidResponse
        }
    }
}

enum NetworkAuthError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case customError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "Invalid URL",
                comment: ""
            )
        case .invalidResponse:
            return NSLocalizedString(
                "Invalid Response",
                comment: ""
            )
        case .customError(let message):
            return NSLocalizedString(
                "\(message)",
                comment: ""
            )
        }
    }

}
