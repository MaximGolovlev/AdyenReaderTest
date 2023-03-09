//
//  ViewController+Refreshes.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import UIKit

extension ViewController {
    
    func configViews() {
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.centerY.equalToSuperview().offset(-200)
            $0.left.right.equalToSuperview().inset(20)
        })
        
        view.addSubview(logsConsole)
        logsConsole.snp.makeConstraints({ $0.left.right.bottom.equalToSuperview() })
        
        mainContainer.addArrangedSubviews([connectDeviceButton, tokenContainer, orderUUIDContainer, transactionButton])
        
        tokenContainer.addArrangedSubviews([tokenLabel, refreshTokenButton])
        orderUUIDContainer.addArrangedSubviews([orderUUIDLabel, refreshOrderUUIDButton])
        
        mainContainer.setCustomSpacing(100, after: connectDeviceButton)
    }
    
    func refreshViews() {
        let tokenButtonTitle = LocalStorage.token == nil ? "Generate\nToken" : "Refresh\nToken"
        refreshTokenButton.setTitle(tokenButtonTitle, for: .normal)
        
        let orderUUIDButtonTitle = LocalStorage.orderUUID == nil ? "Generate\nOrder UUID" : "Refresh\nOrder UUID"
        refreshOrderUUIDButton.setTitle(orderUUIDButtonTitle, for: .normal)
        
        orderUUIDLabel.text = LocalStorage.orderUUID
        tokenLabel.text = LocalStorage.token
    }
    
    func refreshToken() {
        showAlert(title: "Generate Token", message: nil, loginConfigureation: { tf in
            tf.placeholder = "Login"
            tf.text = "admin@admin.com"
        },passwordConfigureation: { tf in
            tf.placeholder = "Password"
            tf.text = "P@ssw0rd"
        }, cancelTitle: "Continue",cancelHandler: { [weak self] (login, password) in
            
            guard let login = login, let password = password else { return }
            
            Task {
                do {
                    let manager = APIManager.refreshToken(login: login, password: password)
                    let response: LoginResponse = try await manager.makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                    LocalStorage.token = response.token
                    self?.refreshViews()
                } catch {
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        })
    }
    
    func refreshOrder() {
        Task {
            do {
                let manager = APIManager.refreshOrderUUID(params: Mocker.orderRequestParams)
                let response: OrderResponse = try await manager.makeRequest(logsHandler: { self.handleLogs(message: $0) })
                LocalStorage.orderUUID = response.order.uuid
                refreshViews()
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func handleLogs(message: String?) {
        DispatchQueue.main.async {
            message.map({ self.logsConsole.insertText($0) })
            self.scrollTextViewToBottom(textView: self.logsConsole)
        }
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
}
