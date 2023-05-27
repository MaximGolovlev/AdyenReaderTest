//
//  APIManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct VoidResult: Codable { }

enum APIManager {
    
    case refreshToken(login: String, password: String)
    case refreshOrderUUID(params: [String: Any])
    case fetchAdyenSetupToken(setupToken: String, id2: String)
    case fetchAdyenSession(orderId2: String)
    
    case auth
    case fetchMenuItems(locationName: String)
    
    case payAdyenOrderLocal(orderUUID: String, POIID: String, postTips: Bool)
    case payAdyenOrderCloud(orderUUID: String, POIID: String, postTips: Bool)
    case checkAdyenPayment(orderUUID: String)
    case captureAdyenPayment(orderId2: String)
    case updateTips(orderUUID: String, request: TipsRequest)
    
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
        case .fetchAdyenSession(let orderId2):
            return "/api/orders/\(orderId2)/pay/adyen/online/session/"
        case .payAdyenOrderLocal(let orderUUID, _, _):
            return "/api/orders/\(orderUUID)/pay/adyen/payment-request/"
        case .payAdyenOrderCloud(let orderUUID, _, _):
            return "/api/orders/\(orderUUID)/pay/adyen/via-terminal/"
        case .checkAdyenPayment(let orderUUID):
            return "/api/orders/\(orderUUID)/pay/adyen/check/"
        case .fetchMenuItems(let locationName):
            let name = locationName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            return "/menu/\(name)/"
        case .updateTips(let orderUUID, _):
            return "/api/orders/\(orderUUID)/tip/"
        case .captureAdyenPayment(let orderId2):
            return "/api/orders/\(orderId2)/pay/adyen/capture/"
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
        case .fetchAdyenSession:
            return .post
        case .payAdyenOrderLocal:
            return .get
        case .payAdyenOrderCloud:
            return .post
        case .checkAdyenPayment:
            return .post
        case .fetchMenuItems:
            return .get
        case .updateTips:
            return .post
        case .captureAdyenPayment:
            return .post
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
        case .fetchAdyenSession:
            return [:]
        case .payAdyenOrderLocal:
            return [:]
        case .payAdyenOrderCloud(_, let POIID, let postTips):
            var params = ["POIID": POIID]
            if postTips {
                params["preauth"] = "True"
            }
            return params
        case .checkAdyenPayment:
            return [:]
        case .fetchMenuItems:
            return [:]
        case .updateTips(_, let request):
            return request.dictionary ?? [:]
        case .captureAdyenPayment:
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
        case .fetchAdyenSession:
            return []
        case .payAdyenOrderLocal(_, let POIID, let postTips):
            var query = [("POIID", POIID)]
            if postTips {
                query.append(("preauth", "True"))
            }
            return query
        case .payAdyenOrderCloud:
            return []
        case .checkAdyenPayment:
            return []
        case .fetchMenuItems:
            return [("fields[]", "menu"),
                    ("fields[]", "items")]
        case .updateTips:
            return []
        case .captureAdyenPayment:
            return []
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .refreshToken:
            return ["Content-Type": "application/json"]
        default:
            return ["Content-Type": "application/json",
                    "Authorization": "Token \(token)",
                    "User-Agent": "ZYRLPad/2023.04.81.2 iOS/16.3.1"]
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
    
    func getData(logsHandler: ((String?) -> ())? = nil) async throws -> Data {
        
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
                
                return data
                
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
    case RequiresCapture
    
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
        case .RequiresCapture:
            return "RequiresCapture"
        }
    }
}

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}
