//
//  Date+Ext.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 19.11.2020.
//  Copyright © 2020 Christopher Sukhram. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "America/Los_Angeles")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
}

extension Date {
    static var localDate: Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}

extension String {
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "America/Los_Angeles")
        dateFormatter.dateFormat = dateFormat
        
        if let data = dateFormatter.date(from: self) {
            return data
        }

        dateFormatter.dateFormat = dateFormat + ".SSSSSS"
        return dateFormatter.date(from: self)
    }
    
}
