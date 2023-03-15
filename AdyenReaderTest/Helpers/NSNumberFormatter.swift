//
//  NSNumberFormatter.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 14.12.2020.
//  Copyright © 2020 Christopher Sukhram. All rights reserved.
//
import Foundation

extension NumberFormatter {

    static var currency: NumberFormatter = {
        $0.numberStyle = .currency
        $0.maximumFractionDigits = 2
        $0.minimumFractionDigits = 2
        $0.locale = Locale(identifier: "en_US")
        $0.roundingMode = .halfUp
        return $0
    }(NumberFormatter())
    
    static var currencyShort: NumberFormatter = {
        $0.numberStyle = .currency
        $0.maximumFractionDigits = 0
        $0.minimumFractionDigits = 0
        $0.locale = Locale(identifier: "en_US")
        $0.roundingMode = .halfUp
        return $0
    }(NumberFormatter())
    
    static var minutes: NumberFormatter = {
        $0.numberStyle = .currency
        $0.maximumFractionDigits = 2
        $0.minimumFractionDigits = 0
        $0.roundingMode = .halfUp
        $0.currencySymbol = ""
        return $0
    }(NumberFormatter())

    static var percent: NumberFormatter = {
        $0.numberStyle = .percent
        return $0
    }(NumberFormatter())
    
    static var number: NumberFormatter = {
        $0.numberStyle = .none
        $0.groupingSeparator = ","
        $0.decimalSeparator = "."
        $0.maximumFractionDigits = 2
        $0.minimumFractionDigits = 0
        return $0
    }(NumberFormatter())
}
