//
//  Models.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import Foundation
import SwiftData

// 项目管理模型
@Model
final class Project {
    var name: String          // 项目名称
    var path: String          // 项目路径
    var timestamp: Date       // 创建或修改时间
    var lastOpened: Date      // 最后打开时间
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
        self.timestamp = Date()
        self.lastOpened = Date()
    }
}

// 数据文件管理模型
@Model
final class DataFile {
    var label: String          // 自定义标签/别名
    var path: String           // 数据文件的完整路径
    var dateAdded: Date        // 添加时间
    
    init(label: String, path: String) {
        self.label = label
        self.path = path
        self.dateAdded = Date()
    }
}

// 标签模板管理模型
@Model
final class TagTemplate {
    var name: String           // 模板名称
    var beginFormat: String    // 开始标签格式
    var endFormat: String      // 结束标签格式
    var isDefault: Bool        // 是否为默认模板
    
    init(name: String, beginFormat: String, endFormat: String, isDefault: Bool = false) {
        self.name = name
        self.beginFormat = beginFormat
        self.endFormat = endFormat
        self.isDefault = isDefault
    }
}
