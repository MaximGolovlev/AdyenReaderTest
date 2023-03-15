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
        presentOrderTypePicker()
    }
    
    private func presentOrderTypePicker() {
        
        let alert = UIAlertController(title: "Choose Order Type", message: nil, preferredStyle: .actionSheet)
        
        let types = OrderRequestMock.allCases
        
        types.forEach({ type in
            let action = UIAlertAction(title: type.title, style: .default, handler: { _ in
                self.refreshOrder(request: type)
            })
            alert.addAction(action)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func refreshOrder(request: OrderRequestMock) {
        Task {
            do {
                let manager = APIManager.refreshOrderUUID(params: request.orderRequest)
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
    
    func presentTerminalPicker(completion: ((Terminal) -> Void)?) {
        
        let alert = UIAlertController(title: "Choose Terminal", message: nil, preferredStyle: .actionSheet)
        
        let newTerminal = UIAlertAction(title: "Add New", style: .default, handler: { _ in
            self.addNewTerminalAlert(completion: completion)
        })
        alert.addAction(newTerminal)
        
        let terminals = LocalStorage.terminals.sorted(by: { $0.time < $1.time })
        
        terminals.forEach({ terminal in
            let action = UIAlertAction(title: terminal.poiid, style: .default, handler: { _ in
                LocalStorage.selectedTerminal = terminal
                completion?(terminal)
            })
            alert.addAction(action)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addNewTerminalAlert(completion: ((Terminal) -> Void)?) {
        showTwoButtonAlert(title: "Add New Terminal", message: "Model and Serial", loginConfigureation: { tf in
            tf.placeholder = "e285p"
        },passwordConfigureation: { tf in
            tf.placeholder = "805373610"
        }, okButtonTitle: "Continue",
                           okHandler: { (model, serial) in
            
            guard let model = model, let serial = serial else { return }
            
            let terminal = Terminal(model: model, serial: serial, time: Date().timeIntervalSince1970)
            var savedTermainals = LocalStorage.terminals
            savedTermainals.append(terminal)
            LocalStorage.terminals = savedTermainals
            
            LocalStorage.selectedTerminal = terminal
            
            completion?(terminal)
        })
    }
    
    func makeTerminalTransaction(poid: String, completion: (() -> ())?) {
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
