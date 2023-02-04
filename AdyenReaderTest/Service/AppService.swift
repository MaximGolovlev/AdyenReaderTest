//
//  NetworkAppService.swift
//  ZYRLUserApp
//
//  Created by Christopher Sukhram on 5/19/20.
//  Copyright © 2020 Christopher Sukhram. All rights reserved.
//

import Foundation
import MapKit

struct VoidResult: Codable { }

enum NetworkAuthError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case customError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "Sorry something went wrong with the network",
                comment: ""
            )
        case .invalidResponse:
            return NSLocalizedString(
                "Server Error",
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

enum AuthServiceError: Error, LocalizedError {
    case networkError
    case serverError
    case serviceError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return NSLocalizedString(
                "Sorry something went wrong with the network",
                comment: ""
            )
        case .serverError:
            return NSLocalizedString(
                "Server Error",
                comment: ""
            )
        case .serviceError(let message):
            return NSLocalizedString(
                "\(message)",
                comment: ""
            )
        }
    }
}

enum AppServiceError: Error {
    case notLoggedIn
}

class AppService {
    
    var baseURL: String {
        type.urlString
    }
    
    private var type: URLType
    
    enum URLType {
        case revi
        case async
        case sync
        case checkout
        
        var urlString: String {
            switch self {
            case .revi:
                return "https://zdash-adyen.getrevi.com/api/orders/"
            case .async:
                return "https://terminal-api-test.adyen.com/async"
            case .sync:
                return "https://terminal-api-test.adyen.com/sync"
            case .checkout:
                return "https://checkout-test.adyen.com/v69/"
            }
        }
    }
    
    init(type: URLType) {
        self.type = type
    }

}

extension AppService {
    
    func fetch<T: Codable>(baseUrl: String? = nil, method: String, query: [(String, String)] = [], headers: [String: String], paramsToPrint: [String: String] = [:], errorTitle: String, className: String, completion: ((Swift.Result<T, Error>) -> Void)?) {
        
        let base = baseUrl ?? self.baseURL
        let urlPath = base + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            completion?(.failure(NetworkAuthError.customError("\(errorTitle): Bad URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        Logger.request(request: url.absoluteString, headers: headers, params: paramsToPrint)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            Logger.response(request: url.absoluteString, data: data)
            
            if let error = error {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(error.localizedDescription)")))
                return
            }
            
            guard let data = data else {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): Invalid Response from the server")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode - 200 < 99 {
                    do {
                        let info = try JSONDecoder().decode(T.self, from: data)
                        completion?(.success(info))
                    } catch {
                        completion?(.failure(AuthServiceError.serviceError("\(errorTitle): unable to parse \(className)")))
                        return
                    }
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let detail = json?["detail"] as? String {
                            completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(detail)")))
                        } else {
                            let message = json.map({ "\(errorTitle): \($0)" }) ?? errorTitle
                            completion?(.failure(AuthServiceError.serviceError(message)))
                        }
                    } catch {
                        completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(error.localizedDescription)")))
                        return
                    }
                }
            } else {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): Invalid Response from the server")))
            }
            
        }.resume()
    }
    
    func post<T: Codable>(httpMethod: String = "POST", method: String, query: [(String, String)] = [], params: [String : Any?], headers: [String: String], errorTitle: String, className: String, completion: ((Swift.Result<T, Error>) -> Void)?) {
        
        let urlPath = baseURL + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            completion?(.failure(NetworkAuthError.customError("\(errorTitle): Bad URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        Logger.request(request: url.absoluteString, headers: headers, params: params)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            var jsonData = data
            
            Logger.response(request: url.absoluteString, data: jsonData)
            
            if let error = error {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(error.localizedDescription)")))
                return
            }
            
            if jsonData?.isEmpty == true {
                jsonData = "{}".data(using: .utf8)
            }
            
            guard let jsonData = jsonData else {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): Invalid Response from the server")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode - 200 < 99 {
                    do {
                        let info = try JSONDecoder().decode(T.self, from: jsonData)
                        completion?(.success(info))
                    } catch {
                        completion?(.failure(AuthServiceError.serviceError("\(errorTitle): unable to parse \(className)")))
                        return
                    }
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        if let detail = json?["detail"] as? String {
                            completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(detail)")))
                        } else {
                            let message = json.map({ "\(errorTitle): \($0)" }) ?? errorTitle
                            completion?(.failure(AuthServiceError.serviceError(message)))
                        }
                    } catch {
                        completion?(.failure(AuthServiceError.serviceError("\(errorTitle): \(error.localizedDescription)")))
                        return
                    }
                }
            } else {
                completion?(.failure(AuthServiceError.serviceError("\(errorTitle): Invalid Response from the server")))
            }
            
        }.resume()
    }
    
    func put<T: Codable>(method: String, query: [(String, String)] = [], params: [String : Any], headers: [String: String], errorTitle: String, className: String, completion: ((Swift.Result<T, Error>) -> Void)?) {
        
        post(httpMethod: "PUT", method: method, query: query, params: params, headers: headers, errorTitle: errorTitle, className: className, completion: completion)
    }
    
}
