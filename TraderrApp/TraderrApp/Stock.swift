//
//  Stock.swift
//  TraderrApp
//
//  Created by ELANUR KIZILAY on 29.07.2023.
//

import Foundation

struct Stock {
    let symbol: String
    let quantity: Double
    let price: Double
    var amount: Double {
        return quantity * price
    }
}
