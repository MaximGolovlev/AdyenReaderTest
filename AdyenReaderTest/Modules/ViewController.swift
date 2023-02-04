//
//  ViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 08.09.2022.
//

import UIKit
import TerminalAPIKit
import Adyen

class ViewController: UIViewController {

    let manager = AdyenReaderManager()
    
    private lazy var presenter = AdyenPresenter(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        manager.setupSession(request: SessionSetupRequest.testRequest) { result in
            switch result {
            case .success(let response):
                print(response.sessionId)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
   //     presenter.requestPaymentData(orderId: "ordr_2EWt8PUKEjtjAGQDqEkKIqJWR1p", POIID: "V400m-111111111")
        
    }
}

extension ViewController: AdyenPresenterDelegate {
    
    func paymentDataDidLoad(item: SaleRequestAdapter) {
        presenter.makePaymentRequest(request: item)
    }
    
    func paymentWasMade(response: PaymentResponse) {
        print(response)
    }
    
    func failed(message: String) {
        print(message)
    }
}

