//
//  ViewController+Refreshes.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

extension ViewController {
    
    func configViews() {
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
        })
        
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
                    let response: LoginResponse = try await APIManager.refreshToken(login: login, password: password).makeRequest()
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
                let response: OrderResponse = try await APIManager.refreshOrderUUID(params: Mocker.orderRequestParams).makeRequest()
                LocalStorage.orderUUID = response.order.uuid
                refreshViews()
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
}
