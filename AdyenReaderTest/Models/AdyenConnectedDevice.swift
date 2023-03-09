//
//  AdyenConnectedDevice.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import AdyenPOS
import Foundation

struct AdyenConnectedDevice {
    let serialNumber: String
    public let name: String?
    public let model: String?
    
    init(_ device: AdyenPOS.ConnectedDevice) {
        self.serialNumber = device.serialNumber
        self.name = device.name
        self.model = device.model
    }
}
