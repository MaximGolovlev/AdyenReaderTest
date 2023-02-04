//
//  AdyenPresenter.swift
//  AdyenReaderTest
//
//  Created by Maxim on 12.09.2022.
//

import Foundation
import TerminalAPIKit

protocol AdyenPresenterDelegate: AnyObject {
    func paymentDataDidLoad(item: SaleRequestAdapter)
    func paymentWasMade(response: PaymentResponse)
    func failed(message: String)
}

class AdyenPresenter {
    
    private let manager = AdyenReaderManager()
    private weak var delegate: AdyenPresenterDelegate?
    
    init(delegate: AdyenPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func requestPaymentData(orderId: String, POIID: String) {
        manager.requestPaymentData(orderId: orderId, POIID: POIID) { [weak self] result in
            switch result {
            case .success(let request):
                self?.delegate?.paymentDataDidLoad(item: request)
            case .failure(let error):
                self?.delegate?.failed(message: error.localizedDescription)
            }
        }
    }
    
    func makePaymentRequest(request: SaleRequestAdapter) {
        manager.makePaymentRequest(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.delegate?.paymentWasMade(response: response)
            case .failure(let error):
                self?.delegate?.failed(message: error.localizedDescription)
            }
        }
    }
    
}
