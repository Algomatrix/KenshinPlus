//
//  Item.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/05.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
