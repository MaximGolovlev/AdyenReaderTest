//
//  ViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 08.09.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var connectDeviceButton: UIButton = {
        $0.setTitle("Connect Device", for: .normal)
        $0.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var transactionButton: UIButton = {
        $0.setTitle("Make Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    var adyenManager = AdyenManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectDeviceButton.sizeToFit()
        transactionButton.sizeToFit()

        view.addSubview(connectDeviceButton)
        view.addSubview(transactionButton)
        
        connectDeviceButton.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        transactionButton.center = CGPoint(x: view.center.x, y: view.center.y + 50)
    }
    
    @objc private func connectButtonTapped() {
        adyenManager.presentDeviceManagement(target: self)
    }
    
    @objc private func makeTransactionTapped() {
        let orderUUID = "b5a1aded-ad69-46f1-8429-5892ea88b6d7"
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: orderUUID)
                
            } catch let DecodingError.dataCorrupted(context) {
                let message = context.debugDescription
                showAlert(message: message)
            } catch let DecodingError.keyNotFound(key, context) {
                let message = "Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
                showAlert(message: message)
            } catch let DecodingError.valueNotFound(value, context) {
                let message = "Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
                showAlert(message: message)
            } catch let DecodingError.typeMismatch(type, context)  {
                let message = "Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)"
                showAlert(message: message)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            
        }
    }
    
}

