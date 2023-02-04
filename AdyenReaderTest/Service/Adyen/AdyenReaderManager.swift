//
//  AdyenReaderManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 08.09.2022.
//

import Foundation
import TerminalAPIKit
import Adyen

class AdyenReaderManager {
    
    let demoServerAPIKey = "AQEwhmfxJo7NbxBFw0m/n3Q5qf3Veo5bBLJJW2pDyGzyzz5/Xoi1a7MtiLTpcaqyQ6ZPEMFdWw2+5HzctViMSCJMYAc=-owvlYYcS3DP75XvpUMR0S8KMVSw6rY8b9ULFZxhm5oY=-G63K9qQLKE;x#I8W"
    
    let posAPIKey = "AQEwhmfxLYvIbRVGw0m/n3Q5qf3Veo5bBLJJW2pDyGzyzz7CrfIHMcAEuTCYzAkCe/gYEMFdWw2+5HzctViMSCJMYAc=-6XfArJj9D7SkwNIPBCJ7BYQK9CMTcKCkxF//Dm7Ppkc=-7sz)W^tT2df8w<?5"
    
    private var appService: AppService?
    
    func setupSession(request: SessionSetupRequest, completion: ((Swift.Result<SessionSetupResponse, Error>) -> ())?) {
        let headers = ["X-API-Key": posAPIKey]
        
        appService = AppService(type: .checkout)
        appService?.post(method: "sessions", params: request.dictionary ?? [:], headers: headers, errorTitle: "setupSession failed", className: "SessionSetupResponse", completion: completion)
    }
    
    func requestPaymentData(orderId: String, POIID: String, completion: ((Swift.Result<SaleRequestAdapter, Error>) -> ())?) {
        
        let params = ["POIID": POIID]
        
        appService = AppService(type: .revi)
        appService?.post(method: "\(orderId)/pay/adyen/build-payment-request/", params: params, headers: [:], errorTitle: "error getting payment request data", className: "SaleRequest", completion: completion)
    }
    
    func makePaymentRequest(request: SaleRequestAdapter, completion: ((Swift.Result<PaymentResponse, Error>) -> ())?) {
        let headers = ["X-API-Key": posAPIKey]
        
        guard let message = request.toTerminalRequest else {
            completion?(.failure(NetworkAuthError.customError("Cannot obtain terminal message")))
            return
        }
        
        appService = AppService(type: .async)
        appService?.post(method: "", params: message.dictionary ?? [:], headers: headers, errorTitle: "makePaymentRequest error", className: "PaymentResponse", completion: completion)
    }
}

