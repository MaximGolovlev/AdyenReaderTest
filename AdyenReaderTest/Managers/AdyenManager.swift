//
//  AdyenManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import AdyenPOS
import UIKit

protocol AdyenManagerDeviceDelegate: AnyObject {
    func onDeviceDiscovered(device: AdyenDevice)
    func onDeviceDiscoveryFailed(with error: Error)
    func onDeviceConnected(device: AdyenConnectedDevice)
    func onDeviceConnectionFail(with error: Error)
    func onDeviceDisconnected()
}

class AdyenManager {
    
    var logsHandler: ((String?) -> ())?
    
    static let shared = AdyenManager()
    
    private var paymentService: PaymentService!
    
    private var poid: String {
        LocalStorage.poiID ?? connectedDevice?.poid ?? ""
    }
    
    weak var deviceDelegate: AdyenManagerDeviceDelegate?
    
    private var sessionResponse: SessionsResponse?
    
    var connectedDevice: AdyenConnectedDevice?
    
    private init() {
        paymentService = PaymentService(delegate: self)
        paymentService.deviceManager.delegate = self
    }
    
    func presentDeviceManagement(target: UIViewController) {
        let vc = DeviceManagementViewController(paymentService: paymentService)
        target.present(vc, animated: true)
    }
    
    func connectToLastKnownDevice() {
        let manager = paymentService.deviceManager
        if let last = manager.knownDevices.last {
            manager.connect(to: last)
        }
    }

    func performTransaction(orderUUID: String, target: UIViewController) async throws -> Transaction.Response {
        let paymentInterface = try await paymentService.getPaymentInterface(with: .cardReader)
        let presentationMode: TransactionPresentationMode = .presentingViewController(target)
        
        let manager = APIManager.payAdyenOrderLocal(orderUUID: orderUUID, POIID: poid)
        let paymentRequest: AdyenPaymentRequest = try await manager.makeRequest(logsHandler: logsHandler)
        let data = try JSONEncoder().encode(paymentRequest)
        let transaction = try Transaction.Request(data: data)
        
        return await paymentService.performTransaction(with: transaction, paymentInterface: paymentInterface, presentationMode: presentationMode)
    }
}

extension AdyenManager: PaymentServiceDelegate {
    
    func register(with setupToken: String) async throws -> String {
        
        let manager = APIManager.fetchAdyenSetupToken(setupToken: setupToken, id2: "bsns_2Fl9Ya7vOUWQ47QbL2RP15Rk8Xg")
        let sessionResponse: SessionsResponse = try await manager.makeRequest(logsHandler: logsHandler)
        self.sessionResponse = sessionResponse
        LocalStorage.poiID = sessionResponse.installationId
        
        return sessionResponse.sdkData
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
