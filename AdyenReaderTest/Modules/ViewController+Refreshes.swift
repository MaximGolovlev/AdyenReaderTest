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
        
        mainContainer.addArrangedSubviews([loginButton, connectDeviceButton, orderUUIDSection, transactionContainer])
        
        transactionContainer.addArrangedSubviews([terminalTransactionButton, transactionButton])
        
        mainContainer.setCustomSpacing(100, after: connectDeviceButton)
    }
    
    func refreshViews() {
        
        let orderUUIDButtonTitle = LocalStorage.orderUUID == nil ? "Generate\nOrder UUID" : "Refresh\nOrder UUID"
        orderUUIDSection.button.setTitle(orderUUIDButtonTitle, for: .normal)
        
        let loginTitle = Globals.isLoggedIn ? "Logout" : "Login"
        loginButton.setTitle(loginTitle, for: .normal)
        
        orderUUIDSection.label.text = LocalStorage.orderUUID
    }
    
    func refreshOrder() {
        Task {
            do {
                let manager = APIManager.refreshOrderUUID(params: Mocker.orderRequest)
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
    
    @objc func loginButtonTapped() {
        
        let vc = LoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        
    }
    
}
