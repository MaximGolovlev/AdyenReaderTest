//
//  ReaderTransactionProvider.swift
//  AdyenReaderTest
//
//  Created by Maxim on 24.05.2023.
//

import UIKit
import AdyenPOS

protocol ReaderTransactionProvider: TransactionProvider {
    
    func makeReaderTransaction()
    func makeReaderTransactionWithPostTips(sourseView: UIView)
    
    func checkingPayment()
    func updatingTips()
    func capturingPayment()
    
    func readerTransactionSucceed(order: Order)
    func readerTransactionCanceled()
    func readerTransactionFailed(message: String)
}

extension ReaderTransactionProvider where Self: UIViewController {
    
    func makeReaderTransaction() {
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: orderUUID, target: self, postTips: false)
                handleLogs(message: Logger.response(request: "adyenManager performTransaction", data: response))
                
                if let object = try? JSONDecoder().decode(AdyenPaymentResponse.self, from: response) {
                    if object.response.paymentResponse.adyenResponse.errorCondition == "Cancel" {
                        readerTransactionCanceled()
                        return
                    }
                }
                
            } catch let error as AdyenPOSError {
                readerTransactionFailed(message: error.description)
            } catch {
                readerTransactionFailed(message: error.localizedDescription)
            }
        }
    }
}

extension ReaderTransactionProvider where Self: UIViewController {
    
    func makeReaderTransactionWithPostTips(sourseView: UIView) {
        Task {
            do {
                let response = try await adyenManager.performTransaction(orderUUID: orderUUID, target: self, postTips: true)
                handleLogs(message: Logger.response(request: "adyenManager performTransaction", data: response))
                
                if let object = try? JSONDecoder().decode(AdyenPaymentResponse.self, from: response) {
                    if object.response.paymentResponse.adyenResponse.errorCondition == "Cancel" {
                        readerTransactionCanceled()
                        return
                    }
                }
                
                try await Task<Never, Never>.sleep(nanoseconds: self.delay)
                
                let _ = try await APIManager.adyenPaymentResponse(orderId2: orderUUID, body: response)
                    .getData(logsHandler: { self.handleLogs(message: $0) })
                
                
                checkPayment(count: 30, requiresCapture: {
                    
                    self.getTipRequest(sourseView: sourseView) { tips in
                        Task {
                            let order: Order = try await APIManager.updateTips(orderUUID: self.orderUUID, request: tips)
                                .makeRequest(logsHandler: { self.handleLogs(message: $0) })
                            try await Task<Never, Never>.sleep(nanoseconds: self.delay)
                            
                            
                            if let id2 = order.id2 {
                                
                                self.capturingPayment()
                                self.capturePayment(id2: id2, count: 30) {
                                    self.readerTransactionSucceed(order: order)
                                }
                            }
                        }
                    }
                })
                
            } catch let error as AdyenPOSError {
                readerTransactionFailed(message: error.description)
            } catch {
                readerTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    func checkPayment(count: Int, requiresCapture: @escaping () async throws -> Void) {
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let order: Order = try await APIManager.checkAdyenPayment(orderUUID: orderUUID)
                    .makeRequest(logsHandler: { self.handleLogs(message: $0) })
                if order.paymentStatus == .paid {
                    self.readerTransactionSucceed(order: order)
                } else {
                    self.continueChecking(count: count, requiresCapture: requiresCapture)
                }
            } catch let status as StatusMessage {
                
                switch status {
                case .InProgress:
                    continueChecking(count: count, requiresCapture: requiresCapture)
                case .RequiresCapture:
                    try await requiresCapture()
                default :
                    readerTransactionFailed(message: status.title)
                }
                
            } catch {
                readerTransactionFailed(message: error.localizedDescription)
            }
        }
    }
    
    private func continueChecking(count: Int, requiresCapture: @escaping () async throws -> Void) {
        
        let count = count - 1
        
        guard count > 0 else {
            readerTransactionFailed(message: "The payment went through, but we could not get a confirmation from the payment system")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.checkPayment(count: count, requiresCapture: requiresCapture)
        })
    }
    
    
    private func capturePayment(id2: String, count: Int, completion: (() -> Void)?) {
        Task { [weak self] in
            do {
                let _: VoidResult = try await APIManager.captureAdyenPayment(orderId2: id2)
                    .makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                 completion?()
            } catch {
                print(error.localizedDescription)
                if error.localizedDescription.lowercased().contains("authorized amount is different") {
                    self?.continueCapturing(id2: id2, count: count, completion: completion)
                } else {
                    self?.readerTransactionFailed(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func continueCapturing(id2: String, count: Int, completion: (() -> Void)?) {
        
        let count = count - 1
        
        guard count > 0 else {
            readerTransactionFailed(message: "The payment went through, but we could not get a confirmation from the payment system")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.capturePayment(id2: id2, count: count, completion: completion)
        })
    }
    
}
