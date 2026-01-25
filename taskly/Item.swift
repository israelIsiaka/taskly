//
//  Item.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
}
