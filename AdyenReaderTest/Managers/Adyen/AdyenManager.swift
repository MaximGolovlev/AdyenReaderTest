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
    
    var paymentService: PaymentService!
    
    var poid: String {
        (try? paymentService.installationId) ?? ""
    }
    
    weak var deviceDelegate: AdyenManagerDeviceDelegate?
    
    private var sessionResponse: POSSessionsResponse?
    
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
}

extension AdyenManager: PaymentServiceDelegate {
    
    func register(with setupToken: String) async throws -> String {
        
        let manager = APIManager.fetchAdyenSetupToken(setupToken: setupToken, id2: LocalStorage.restaurant?.id2 ?? "")
        let sessionResponse: POSSessionsResponse = try await manager.makeRequest(logsHandler: logsHandler)
        self.sessionResponse = sessionResponse
        return sessionResponse.sdkData
    }

}

