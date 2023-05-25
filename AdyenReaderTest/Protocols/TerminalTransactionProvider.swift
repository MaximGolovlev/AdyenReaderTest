//
//  TransactionProvider+Terminal.swift
//  AdyenReaderTest
//
//  Created by Maxim on 24.05.2023.
//

import UIKit
import AdyenPOS

protocol TerminalTransactionProvider: TransactionProvider {
    
    var terminal: Terminal { get set }
    
    func makeTerminalTransaction()
    func makeTerminalTransactionWithPostTips(sourseView: UIView)
    
    func showProgressLoader()
    func hideProgressLoader()
    
    func checkingPayment()
    func updatingTips()
    func capturingPayment()
    
    func terminalTransactionWasInitiated()
    func terminalTransactionSucceed(order: Order)
    func terminalTransactionFailed(message: String)
}

extension TerminalTransactionProvider where Self: UIViewController {
    
    func makeTerminalTransaction() {
        Task {
            do {
                let response: TerminalPaymentResponse = try await APIManager.payAdyenOrderCloud(orderUUID: orderUUID, POIID: terminal.poiid, postTips: false)
                    .makeRequest(logsHandler: { self.handleLogs(message: $0) })
                
                if response.status == "ok" {
                    terminalTransactionWasInitiated()
                }
                
                checkTerminalPayment()
                
            } catch let error as AdyenPOSError {
                terminalTransactionFailed(message: error.description)
            } catch {
                terminalTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func checkTerminalPayment() {
        Task { [weak self] in
            do {
                let order: Order = try await APIManager.checkAdyenPayment(orderUUID: orderUUID)
                    .makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                if order.paymentStatus == .paid {
                    self?.terminalTransactionSucceed(order: order)
                } else {
                    self?.continueChecking()
                }
            } catch let status as StatusMessage {
                
                switch status {
                case .InProgress:
                    showProgressLoader()
                    continueChecking()
                default :
                    hideProgressLoader()
                    terminalTransactionFailed(message: status.title)
                }
                
            } catch {
                terminalTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func continueChecking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.checkTerminalPayment()
        })
    }
    
}

extension TerminalTransactionProvider where Self: UIViewController {
    
    func makeTerminalTransactionWithPostTips(sourseView: UIView) {
        Task {
            do {
                let response: TerminalPaymentResponse = try await APIManager.payAdyenOrderCloud(orderUUID: orderUUID, POIID: terminal.poiid, postTips: true)
                    .makeRequest(logsHandler: { self.handleLogs(message: $0) })

                if response.status == "ok" {
                    terminalTransactionWasInitiated()
                }
                
                try await Task<Never, Never>.sleep(nanoseconds: self.delay)
                
                checkPayment(count: 30, requiresCapture: {
                    
                    self.getTipRequest(sourseView: sourseView) { tips in
                        
                        self.updatingTips()
                        self.updateTips(tips: tips) { order in
                            if let id2 = order.id2 {
                                
                                self.capturingPayment()
                                self.capturePayment(id2: id2, count: 30) {
                                    
                                    self.terminalTransactionSucceed(order: order)
                                }
                            }
                        }
                    }
                })
                
            } catch let error as AdyenPOSError {
                terminalTransactionFailed(message: error.description)
            } catch {
                terminalTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func updateTips(tips: TipsRequest, completion: ((Order) -> Void)? ) {
        Task {
            do {
                let order: Order = try await APIManager.updateTips(orderUUID: self.orderUUID, request: tips)
                    .makeRequest(logsHandler: { self.handleLogs(message: $0) })
                try await Task<Never, Never>.sleep(nanoseconds: self.delay)
                completion?(order)
            } catch let error as AdyenPOSError {
                self.terminalTransactionFailed(message: error.description)
            } catch {
                self.terminalTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func checkPayment(count: Int, requiresCapture: @escaping () async throws -> Void) {
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let order: Order = try await APIManager.checkAdyenPayment(orderUUID: orderUUID)
                    .makeRequest(logsHandler: { self.handleLogs(message: $0) })
                if order.paymentStatus == .paid {
                    self.terminalTransactionSucceed(order: order)
                } else {
                    self.continueChecking(count: count, requiresCapture: requiresCapture)
                }
            } catch let status as StatusMessage {
                
                switch status {
                case .InProgress:
                    showProgressLoader()
                    continueChecking(count: count, requiresCapture: requiresCapture)
                case .RequiresCapture:
                    try await requiresCapture()
                default :
                    hideProgressLoader()
                    terminalTransactionFailed(message: status.title)
                }
                
            } catch {
                terminalTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func continueChecking(count: Int, requiresCapture: @escaping () async throws -> Void) {
        
        let count = count - 1
        
        guard count > 0 else {
            terminalTransactionFailed(message: "The payment went through, but we could not get a confirmation from the payment system")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.checkPayment(count: count, requiresCapture: requiresCapture)
        })
    }
    
    private func capturePayment(id2: String, count: Int, completion: (() -> Void)?) {
        Task { [weak self] in
            do {
                let void: VoidResult = try await APIManager.captureAdyenPayment(orderId2: id2)
                    .makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                 completion?()
            } catch {
                print(error.localizedDescription)
                if error.localizedDescription.lowercased().contains("authorized amount is different") {
                    continueCapturing(id2: id2, count: count, completion: completion)
                } else {
                    terminalTransactionFailed(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func continueCapturing(id2: String, count: Int, completion: (() -> Void)?) {
        
        let count = count - 1
        
        guard count > 0 else {
            terminalTransactionFailed(message: "The payment went through, but we could not get a confirmation from the payment system")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.capturePayment(id2: id2, count: count, completion: completion)
        })
    }
    
}
