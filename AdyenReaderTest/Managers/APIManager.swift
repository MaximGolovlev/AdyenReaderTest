//
//  APIManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

enum APIManager {
    
    case refreshToken(login: String, password: String)
    case refreshOrderUUID(params: [String: Any])
    
    case fetchAdyenSetupToken(setupToken: String, id2: String)
    case payAdyenOrderLocal(orderUUID: String, POIID: String)
    case payAdyenOrderCloud(orderUUID: String, POIID: String)
    case checkAdyenPayment(orderUUID: String)
    
    case payWithAdyenTerminal(orderUUID: String, POIID: String)
    
    case auth
    case fetchMenuItems(locationName: String)
    
    var baseURL: String {
        return LocalStorage.environment.url
    }
    
    var token: String {
        return LocalStorage.token ?? ""
    }
    
    var method: String {
        switch self {
        case .auth:
            return "/auth/partner/me/"
        case .refreshToken:
            return "/auth/partner/login/"
        case .refreshOrderUUID:
            return "/api/orders/"
        case .fetchAdyenSetupToken:
            return "/api/adyen/terminals/sessions/"
        case .payAdyenOrderLocal(let orderUUID, _):
            return "/api/orders/\(orderUUID)/pay/adyen/payment-request/"
        case .payAdyenOrderCloud(let orderUUID, _):
            return "/api/orders/\(orderUUID)/pay/adyen/via-terminal/"
        case .checkAdyenPayment(let orderUUID):
            return "/api/orders/\(orderUUID)/pay/adyen/check/"
        case .payWithAdyenTerminal(let orderUUID, _):
            return "/api/orders/\(orderUUID)/pay/adyen/via-terminal/"
        case .fetchMenuItems(let locationName):
            let name = locationName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            return "/menu/\(name)/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .auth:
            return .get
        case .refreshToken:
            return .post
        case .refreshOrderUUID:
            return .post
        case .fetchAdyenSetupToken:
            return .post
        case .payAdyenOrderLocal:
            return .get
        case .payAdyenOrderCloud:
            return .get
        case .checkAdyenPayment:
            return .post
        case .payWithAdyenTerminal:
            return .post
        case .fetchMenuItems:
            return .get
        }
    }
    
    var params: [String: Any] {
        
        switch self {
        case .auth:
            return [:]
        case .refreshToken(let login, let password):
            return ["password": "\(password)", "username": "\(login)", "to": "REVIPAD"]
        case .refreshOrderUUID(let params):
            return params
        case .fetchAdyenSetupToken(let setupToken, let id2):
            return ["setup_token": setupToken, "business": id2]
        case .payAdyenOrderLocal:
            return [:]
        case .payAdyenOrderCloud:
            return [:]
        case .checkAdyenPayment:
            return [:]
        case .payWithAdyenTerminal(_, let POIID):
            return ["POIID": POIID]
        case .fetchMenuItems:
            return [:]
        }
    }
    
    var query: [(String, String)] {
        switch self {
        case .auth:
            return [("expand", "businesses"), ("expand", "permissions")]
        case .refreshToken:
            return []
        case .refreshOrderUUID:
            return []
        case .fetchAdyenSetupToken:
            return []
        case .payAdyenOrderLocal(_, let POIID):
            return [("POIID", POIID)]
        case .payAdyenOrderCloud(_, let POIID):
            return [("POIID", POIID)]
        case .checkAdyenPayment:
            return []
        case .payWithAdyenTerminal:
            return []
        case .fetchMenuItems:
            return [("fields[]", "menu"),
                    ("fields[]", "items")]
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .refreshToken:
            return ["Content-Type": "application/json"]
        default:
            return ["Content-Type": "application/json",
             "Authorization": "Token \(token)"]
        }
    }
    
    func makeRequest<T: Codable>(logsHandler: ((String?) -> ())? = nil) async throws -> T {
        
        let urlPath = baseURL + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            throw NetworkAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        if httpMethod == .post {
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            request.httpBody = jsonData
        }
        
        let requestLog = Logger.request(request: url.absoluteString, headers: headers, params: params)
        logsHandler?(requestLog)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let responseLog = Logger.response(request: url.absoluteString, data: data)
        logsHandler?(responseLog)
        
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
                
                if let string = json?["status"] as? String, let status = StatusMessage(rawValue: string) {
                    throw status
                }
                
                if let detail = json?["detail"] as? String {
                    throw NetworkAuthError.customError(detail)
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

enum StatusMessage: String, Error {
    case Aborted
    case InProgress
    case NotFound
    case Cancel
    case Busy
    
    var title: String {
        switch self {
        case .Aborted:
            return "Aborted"
        case .InProgress:
            return "In Progress"
        case .NotFound:
            return "Not Found"
        case .Cancel:
            return "Canceled"
        case .Busy:
            return "Busy"
        }
    }
}

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}
