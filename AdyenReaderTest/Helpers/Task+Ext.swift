//
//  Task+Ext.swift
//  ZYRLPad
//
//  Created by Maxim on 11.04.2023.
//  Copyright © 2023 iOS Master. All rights reserved.
//

import Foundation


extension Task where Failure == Error {
    @discardableResult
    static func retryAdyenCapture(priority: TaskPriority? = nil,
                                  maxRetryCount: Int = 15,
                                  retryDelay: TimeInterval = 2,
                                  operation: @Sendable @escaping () async throws -> Success) -> Task {
        
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    
                    if error.localizedDescription == "authorized_amount_is_different" {
                        let oneSecond = TimeInterval(1_000_000_000)
                        let delay = UInt64(oneSecond * retryDelay)
                        try await Task<Never, Never>.sleep(nanoseconds: delay)
                        continue
                    }
                    
                    throw error
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}

extension Task where Failure == Error, Success == Order {
    
    @discardableResult
    static func retryAdyenPaymentChack(priority: TaskPriority? = nil,
                                       maxRetryCount: Int = 1,
                                       retryDelay: TimeInterval = 2,
                                       operation: @Sendable @escaping () async throws -> Success,
                                       requiresCapture: (() async throws -> ())? = nil) -> Task {
        
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    
                    let order: Order = try await operation()
                    
                    if order.paymentStatus == .paid {
                        return order
                    } else {
                        let oneSecond = TimeInterval(1_000_000_000)
                        let delay = UInt64(oneSecond * retryDelay)
                        try await Task<Never, Never>.sleep(nanoseconds: delay)
                        continue
                    }
                    
                } catch let status as StatusMessage {
                    
                    switch status {
                    case .InProgress:
                        let oneSecond = TimeInterval(1_000_000_000)
                        let delay = UInt64(oneSecond * retryDelay)
                        try await Task<Never, Never>.sleep(nanoseconds: delay)
                        continue
                        
                    case .RequiresCapture:
                        try await requiresCapture?()
                    default :
                        throw status
                    }
                    
                } catch {
                    throw error
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}

