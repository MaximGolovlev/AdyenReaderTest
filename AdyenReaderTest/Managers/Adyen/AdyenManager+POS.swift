//
//  AdyenManager+Reader.swift
//  AdyenReaderTest
//
//  Created by Maxim on 26.05.2023.
//

import UIKit
import AdyenPOS

extension AdyenManager {
    
    func performTransaction(orderUUID: String, target: UIViewController, postTips: Bool = false) async throws -> Payment.Response {
        let paymentInterface = try await paymentService.getPaymentInterface(with: .cardReader)
        let presentationMode: TransactionPresentationMode = .presentingViewController(target)
        
        let manager = APIManager.payAdyenOrderLocal(orderUUID: orderUUID, POIID: poid, postTips: postTips)
        let paymentRequestData = try await manager.getData(logsHandler: logsHandler)
        let transaction = try Payment.Request(data: paymentRequestData)
        
        return await paymentService.performTransaction(with: transaction, paymentInterface: paymentInterface, presentationMode: presentationMode)
    }
    
}

extension AdyenManager: DeviceManagerDelegate {
    
    func onDeviceDiscovered(device: AdyenPOS.Device, by manager: AdyenPOS.DeviceManager) {
        deviceDelegate?.onDeviceDiscovered(device: AdyenDevice(device))
    }
    
    func onDeviceDiscoveryFailed(with error: Error, by manager: AdyenPOS.DeviceManager) {
        deviceDelegate?.onDeviceDiscoveryFailed(with: error)
    }
    
    func onDeviceConnected(with error: Error?, to manager: AdyenPOS.DeviceManager) {
        if let device = manager.connectedDevice, error == nil {
            let connectedDevice = AdyenConnectedDevice(device)
            self.connectedDevice = connectedDevice
            deviceDelegate?.onDeviceConnected(device: connectedDevice)
        } else if let error = error {
            deviceDelegate?.onDeviceConnectionFail(with: error)
        }
    }
    
    func onDeviceDisconnected(from manager: AdyenPOS.DeviceManager) {
        deviceDelegate?.onDeviceDisconnected()
    }
    
}
