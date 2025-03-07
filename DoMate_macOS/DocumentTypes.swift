//
//  DocumentTypes.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import UniformTypeIdentifiers

// 为do文件定义文件类型
extension UTType {
    static var doFile: UTType {
        UTType(importedAs: "com.stata.do")
    }
}

// do文件文档结构
struct DoDocument: FileDocument {
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    static var readableContentTypes: [UTType] { [.doFile, .plainText] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
