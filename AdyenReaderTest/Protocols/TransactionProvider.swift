//
//  TransactionProvider.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit

protocol TransactionProvider {
    
    typealias TipsRequestHandler = ((@escaping (TipsRequest) -> ()) async throws -> ())
    
    var adyenManager: AdyenManager { get }
    var orderUUID: String { get }
    var menuItems: [MenuItem] { get }
    var logsConsole: UITextView { get set }
    
    func refreshViews()
    func handleLogs(message: String?)
    func scrollTextViewToBottom(textView: UITextView)
}

extension TransactionProvider where Self: UIViewController {

    var delay: UInt64 {
        let oneSecond = TimeInterval(1_000_000_000)
        let delay = UInt64(oneSecond * 2)
        return delay
    }
    
    func fetchMenuItems(sourceView: UIView) {
        
        Task {
            do {
                let name = LocalStorage.restaurant?.name ?? ""
                let response: MenuResponse = try await APIManager.fetchMenuItems(locationName: name).makeRequest()
                let items = response.menuItems
                DispatchQueue.main.async {
                    self.presentMenuItemPicker(sourceView: sourceView, items: items)
                }
            } catch {
                await self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func presentMenuItemPicker(sourceView: UIView, items: [MenuItem]) {
        
        let alert = UIAlertController(title: "Select Menu Item", message: nil, preferredStyle: .actionSheet)
        
        items.forEach({ menuItem in
            let action = UIAlertAction(title: menuItem.description, style: .default, handler: { _ in
                LocalStorage.orderRequestType = .regular
                LocalStorage.menuItems = [menuItem]
                self.refreshViews()
            })
            alert.addAction(action)
        })
        
        var dollar = items.first(where: { $0.name.lowercased() == "1 dollar" })!
        var tenCents = items.first(where: { $0.name.lowercased() == "10 cents" })!
        var oneCent = items.first(where: { $0.name.lowercased() == "1 cents" })!
        
        let authorised = UIAlertAction(title: OrderRequestType.authorised.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .authorised
            dollar.quantity = 1
            LocalStorage.menuItems = [dollar]
            self.refreshViews()
        })
        alert.addAction(authorised)
        
        let declined = UIAlertAction(title: OrderRequestType.declined.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .declined
            dollar.quantity = 1
            tenCents.quantity = 2
            oneCent.quantity = 3
            LocalStorage.menuItems = [dollar,
                                      tenCents,
                                      oneCent]
            self.refreshViews()
        })
        alert.addAction(declined)
        
        let notEnoughBalance = UIAlertAction(title: OrderRequestType.notEnoughBalance.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .notEnoughBalance
            dollar.quantity = 1
            tenCents.quantity = 2
            oneCent.quantity = 4
            LocalStorage.menuItems = [dollar,
                                      tenCents,
                                      oneCent]
            self.refreshViews()
        })
        alert.addAction(notEnoughBalance)
        
        let blockedCard = UIAlertAction(title: OrderRequestType.blockedCard.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .blockedCard
            dollar.quantity = 1
            tenCents.quantity = 2
            oneCent.quantity = 5
            LocalStorage.menuItems = [dollar,
                                      tenCents,
                                      oneCent]
            self.refreshViews()
        })
        alert.addAction(blockedCard)
        
        let cardExpired = UIAlertAction(title: OrderRequestType.cardExpired.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .cardExpired
            dollar.quantity = 1
            tenCents.quantity = 2
            oneCent.quantity = 6
            LocalStorage.menuItems = [dollar,
                                      tenCents,
                                      oneCent]
            self.refreshViews()
        })
        alert.addAction(cardExpired)
        
        let invalidOnlinePIN = UIAlertAction(title: OrderRequestType.invalidOnlinePIN.title, style: .default, handler: { _ in
            LocalStorage.orderRequestType = .invalidOnlinePIN
            dollar.quantity = 1
            tenCents.quantity = 3
            oneCent.quantity = 4
            LocalStorage.menuItems = [dollar,
                                      tenCents,
                                      oneCent]
            self.refreshViews()
        })
        alert.addAction(invalidOnlinePIN)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refreshOrder(request: OrderRequestMock) {
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
    
    func presentTerminalPicker(sourceView: UIView, completion: ((Terminal) -> Void)?) {
        
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
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
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
    
    func getTipRequest(sourseView: UIView, completion: ((TipsRequest) -> Void)?) {
        DispatchQueue.main.async {
            let tips = [TipsRequest(tipCents: 100, type: .dollars),
                        TipsRequest(tipCents: 200, type: .dollars),
                        TipsRequest(tipCents: 300, type: .dollars),
                        TipsRequest(tipCents: 400, type: .dollars)]
            self.presentTipsPicker(sourceView: sourseView, tips: tips, completion: completion)
        }
    }
    
    func presentTipsPicker(sourceView: UIView, tips: [TipsRequest], completion: ((TipsRequest) -> Void)?) {
        
        let alert = UIAlertController(title: "Select Tips", message: nil, preferredStyle: .actionSheet)
        
        tips.forEach({ tip in
            let action = UIAlertAction(title: tip.nameString, style: .default, handler: { _ in
                completion?(tip)
            })
            alert.addAction(action)
        })
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
