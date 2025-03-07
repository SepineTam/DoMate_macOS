//
//  Item.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
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
