//
//  ViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 08.09.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    var tokenContainer: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    var tokenLabel: UILabel = {
        $0.text = LocalStorage.token
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var refreshTokenButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.addTarget(self, action: #selector(refreshTokenTapped), for: .touchUpInside)
        $0.snp.makeConstraints({ $0.width.equalTo(120) })
        return $0
    }(UIButton(type: .system))
    
    var orderUUIDContainer: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    var orderUUIDLabel: UILabel = {
        $0.text = LocalStorage.orderUUID
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var refreshOrderUUIDButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.addTarget(self, action: #selector(refreshOrderUUIDTapped), for: .touchUpInside)
        $0.snp.makeConstraints({ $0.width.equalTo(120) })
        return $0
    }(UIButton(type: .system))
    
    lazy var connectDeviceButton: UIButton = {
        $0.setTitle("Connect Device", for: .normal)
        $0.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var transactionButton: UIButton = {
        $0.setTitle("Make Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private var adyenManager = AdyenManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViews()
        refreshViews()
    }
    
    @objc private func connectButtonTapped() {
        adyenManager.presentDeviceManagement(target: self)
    }
    
    @objc private func makeTransactionTapped() {
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: LocalStorage.orderUUID ?? "")
                showAlert(message: "Transaction succeed!")
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    @objc private func refreshTokenTapped() {
        refreshToken()
    }
    
    @objc private func refreshOrderUUIDTapped() {
        refreshOrder()
    }
    
}

