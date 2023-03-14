//
//  TransactionProvider.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit
import AdyenPOS

protocol TransactionProvider {
    
    var adyenManager: AdyenManager { get }
    var orderUUID: String { get }
    var logsConsole: UITextView { get set }
    
    func makeReaderTransaction()
    
    func refreshOrder()
    func handleLogs(message: String?)
    func scrollTextViewToBottom(textView: UITextView)
    func refreshViews()
}

extension TransactionProvider where Self: UIViewController {
    
    
    func refreshOrder() {
        Task {
            do {
                let manager = APIManager.refreshOrderUUID(params: Mocker.orderRequest)
                let response: OrderResponse = try await manager.makeRequest(logsHandler: { self.handleLogs(message: $0) })
                LocalStorage.order = response.order
                DispatchQueue.main.async {
                    self.refreshViews()
                }
            } catch {
                await showAlert(message: error.localizedDescription)
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
        DispatchQueue.main.async {
            if textView.text.count > 0 {
                let location = textView.text.count - 1
                let bottom = NSMakeRange(location, 1)
                textView.scrollRangeToVisible(bottom)
            }
        }
    }
    
    func makeReaderTransaction() {
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: orderUUID, target: self)
                handleLogs(message: Logger.response(request: "adyenManager performTransaction", data: response))
                
                // let object = try JSONDecoder().decode(AdyenPaymentResponse.self, from: response)
                print(response)
            } catch let error as AdyenPOSError {
                await showAlert(message: error.description)
            } catch {
                await showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func makeTerminalTransaction(completion: (() -> ())?) {
        
        showTwoButtonAlert(title: "Terminal Transaction", message: "Model and Serial", loginConfigureation: { tf in
            tf.placeholder = "e285p"
            tf.text = LocalStorage.terminalModel ?? "e285p"
        },passwordConfigureation: { tf in
            tf.placeholder = "805373610"
            tf.text = LocalStorage.terminalSerial ?? "805373610"
        }, okButtonTitle: "Continue",
                           okHandler: { [weak self] (model, serial) in
            
            guard let model = model, let serial = serial else { return }
            
            LocalStorage.terminalModel = model
            LocalStorage.terminalSerial = serial
            
            let poid = "\(model)-\(serial)"
            
            self?.makeTerminalTransaction(poid: poid, completion: completion)
        })
    }
    
    private func makeTerminalTransaction(poid: String, completion: (() -> ())?) {
        Task {
            do {
                let response: TerminalPaymentResponse = try await APIManager.payWithAdyenTerminal(orderUUID: orderUUID, POIID: poid).makeRequest(logsHandler: { self.handleLogs(message: $0) })
                
                if response.status == "ok" {
                    completion?()
                }
                
            } catch let error as AdyenPOSError {
                await showAlert(message: error.description)
            } catch {
                await showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func checkTransaction() {
        
    }
}
