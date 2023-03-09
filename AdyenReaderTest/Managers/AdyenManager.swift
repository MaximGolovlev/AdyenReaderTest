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
    
    static let shared = AdyenManager()
    
    private var paymentService: PaymentService!
    
    private var poid: String {
        sessionResponse?.installationId ?? ""
    }
    
    weak var deviceDelegate: AdyenManagerDeviceDelegate?
    
    private var sessionResponse: SessionsResponse?
    
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

    func performTransaction(orderUUID: String) async throws -> Transaction.Response {
        let paymentInterface = try await paymentService.getPaymentInterface(with: .cardReader)
        let presentationMode: TransactionPresentationMode = .viewModifier
        
        let manager = APIManager.payAdyenOrderLocal(orderUUID: orderUUID, POIID: poid)
        let paymentRequest: AdyenPaymentRequest = try await manager.makeRequest()
        let data = try JSONEncoder().encode(paymentRequest)
        let transaction = try Transaction.Request(data: data)
        
        return await paymentService.performTransaction(with: transaction, paymentInterface: paymentInterface, presentationMode: presentationMode)
    }
}

extension AdyenManager: PaymentServiceDelegate {
    
    func register(with setupToken: String) async throws -> String {
        
        let manager = APIManager.fetchAdyenSetupToken(setupToken: setupToken, id2: "bsns_1xqU7FT5OorUjbzQsR15KufTfCP")
        let sessionResponse: SessionsResponse = try await manager.makeRequest()
        self.sessionResponse = sessionResponse
        
        return sessionResponse.sdkData
    }

}

extension AdyenManager: DeviceManagerDelegate {
    
    func onDeviceDiscovered(device: AdyenPOS.Device, by manager: AdyenPOS.DeviceManager) {

    }
    
    func onDeviceDiscoveryFailed(with error: Error, by manager: AdyenPOS.DeviceManager) {

    }
    
    func onDeviceConnected(with error: Error?, to manager: AdyenPOS.DeviceManager) {

    }
    
    func onDeviceDisconnected(from manager: AdyenPOS.DeviceManager) {

    }
    
}
