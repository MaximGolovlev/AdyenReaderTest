//
//  AdyenDevice.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import AdyenPOS
import Foundation


struct AdyenDevice {
    let serialNumber: String
    
    init(_ device: AdyenPOS.Device) {
        self.serialNumber = device.serialNumber
    }
}
