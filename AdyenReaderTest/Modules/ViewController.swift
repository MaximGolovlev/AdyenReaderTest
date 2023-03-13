//
//  ViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 08.09.2022.
//

import UIKit
import SnapKit
import AdyenPOS

class ViewController: UIViewController {
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var loginButton: UIButton = {
        $0.setTitle("Login", for: .normal)
        $0.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var connectDeviceButton: UIButton = {
        $0.setTitle("Connect Device", for: .normal)
        $0.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var orderUUIDSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.refreshOrder()
    })
    
    var transactionContainer: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var terminalTransactionButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.setTitle("Make\nTerminal Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTerminalTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var transactionButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.setTitle("Make\nReader Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var logsConsole: UITextView = {
        $0.isEditable = false
        $0.snp.makeConstraints({ $0.height.equalTo(400) })
        return $0
    }(UITextView())
    
    private var adyenManager = AdyenManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViews()
        refreshViews()
        
        adyenManager.connectToLastKnownDevice()
        adyenManager.logsHandler = handleLogs(message:)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Globals.isLoggedIn {
            loginButtonTapped()
        }
    }
    
    @objc private func connectButtonTapped() {
        adyenManager.presentDeviceManagement(target: self)
    }
    
    @objc private func makeTransactionTapped() {
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: LocalStorage.orderUUID ?? "", target: self)
                handleLogs(message: Logger.response(request: "adyenManager performTransaction", data: response))
                
               // let object = try JSONDecoder().decode(AdyenPaymentResponse.self, from: response)
                print(response)
            } catch let error as AdyenPOSError {
                showAlert(message: error.description)
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    @objc private func makeTerminalTransactionTapped() {
        
        showAlert(title: "Terminal Transaction", message: "Model and Serial", loginConfigureation: { tf in
            tf.placeholder = "e285p"
            tf.text = LocalStorage.terminalModel ?? "e285p"
        },passwordConfigureation: { tf in
            tf.placeholder = "805373610"
            tf.text = LocalStorage.terminalSerial ?? "805373610"
        }, cancelTitle: "Continue",cancelHandler: { [weak self] (model, serial) in
            
            guard let model = model, let serial = serial else { return }
            
            LocalStorage.terminalModel = model
            LocalStorage.terminalSerial = serial
            
            let poid = "\(model)-\(serial)"
            
            Task {
                do {
                    let orderId = LocalStorage.orderUUID ?? ""
                    let _: VoidResponse = try await APIManager.payWithAdyenTerminal(orderUUID: orderId, POIID: poid).makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                    
                } catch let error as AdyenPOSError {
                    self?.showAlert(message: error.description)
                } catch {
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        })
    }
    
    
}

