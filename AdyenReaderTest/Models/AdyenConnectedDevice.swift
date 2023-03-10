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
    let name: String?
    let model: String?
    let type: String?
    
    var poid: String? {
        return [type, serialNumber].compactMap({ $0 }).joined(separator: "-")
    }
    
    init(_ device: AdyenPOS.ConnectedDevice) {
        self.serialNumber = device.serialNumber
        self.name = device.name
        self.model = device.model
        self.type = device.type.rawValue
    }
}
