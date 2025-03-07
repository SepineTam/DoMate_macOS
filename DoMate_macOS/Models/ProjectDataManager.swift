//
//  ProjectDataManager.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import Foundation

// 数据文件元数据模型
struct DataFileMetadata: Codable, Identifiable {
    var id = UUID()
    var label: String
    var path: String
    var dateAdded: Date
    var tags: [String] = []
    
    // 用于初始化新数据
    init(label: String, path: String, tags: [String] = []) {
        self.label = label
        self.path = path
        self.dateAdded = Date()
        self.tags = tags
    }
}

// 项目标签类别模型
struct TagCategory: Codable, Identifiable {
    var id = UUID()
    var name: String
    var tags: [String]
    
    init(name: String, tags: [String] = []) {
        self.name = name
        self.tags = tags
    }
}

// 项目元数据模型
struct ProjectMetadata: Codable {
    var dataFiles: [DataFileMetadata] = []
    var tagCategories: [TagCategory] = []
    var lastModified: Date = Date()
    
    // 初始化一个空的项目元数据
    init() {}
}

// 项目数据管理类
class ProjectDataManager {
    
    // 项目URL
    private let projectURL: URL
    
    // 元数据文件名
    private let metadataFileName = "domate-metadata.json"
    
    // 项目元数据
    private var metadata: ProjectMetadata
    
    // 初始化
    init(projectURL: URL) {
        self.projectURL = projectURL
        self.metadata = ProjectMetadata()
        
        // 尝试加载现有元数据
        loadMetadata()
    }
    
    // 元数据文件的URL
    private var metadataURL: URL {
        projectURL.appendingPathComponent(metadataFileName)
    }
    
    // 加载元数据
    private func loadMetadata() {
        do {
            if FileManager.default.fileExists(atPath: metadataURL.path) {
                let data = try Data(contentsOf: metadataURL)
                let decoder = JSONDecoder()
                metadata = try decoder.decode(ProjectMetadata.self, from: data)
                print("成功加载项目元数据")
            } else {
                // 文件不存在，创建一个空的元数据并保存
                metadata = ProjectMetadata()
                try saveMetadata()
                print("创建了新的项目元数据文件")
            }
        } catch {
            print("加载项目元数据失败: \(error.localizedDescription)")
            // 出错时创建一个新的元数据
            metadata = ProjectMetadata()
        }
    }
    
    // 保存元数据
    private func saveMetadata() throws {
        metadata.lastModified = Date()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(metadata)
        try data.write(to: metadataURL)
    }
    
    // MARK: - 数据文件管理
    
    // 获取所有数据文件
    func getAllDataFiles() -> [DataFileMetadata] {
        return metadata.dataFiles
    }
    
    // 添加数据文件
    func addDataFile(label: String, path: String, tags: [String] = []) throws -> DataFileMetadata {
        let newFile = DataFileMetadata(label: label, path: path, tags: tags)
        metadata.dataFiles.append(newFile)
        try saveMetadata()
        return newFile
    }
    
    // 更新数据文件
    func updateDataFile(id: UUID, newLabel: String, newPath: String, newTags: [String]? = nil) throws {
        if let index = metadata.dataFiles.firstIndex(where: { $0.id == id }) {
            metadata.dataFiles[index].label = newLabel
            metadata.dataFiles[index].path = newPath
            
            if let tags = newTags {
                metadata.dataFiles[index].tags = tags
            }
            
            try saveMetadata()
        }
    }
    
    // 删除数据文件
    func deleteDataFile(id: UUID) throws {
        metadata.dataFiles.removeAll { $0.id == id }
        try saveMetadata()
    }
    
    // 根据标签查找数据文件
    func findDataFilesByTag(tag: String) -> [DataFileMetadata] {
        return metadata.dataFiles.filter { $0.tags.contains(tag) }
    }
    
    // MARK: - 标签类别管理
    
    // 获取所有标签类别
    func getAllTagCategories() -> [TagCategory] {
        return metadata.tagCategories
    }
    
    // 获取所有标签（扁平列表）
    func getAllTags() -> [String] {
        var allTags = Set<String>()
        
        // 从标签类别中收集
        for category in metadata.tagCategories {
            for tag in category.tags {
                allTags.insert(tag)
            }
        }
        
        // 从已使用的标签中收集
        for file in metadata.dataFiles {
            for tag in file.tags {
                allTags.insert(tag)
            }
        }
        
        return Array(allTags).sorted()
    }
    
    // 添加标签类别
    func addTagCategory(name: String, tags: [String] = []) throws -> TagCategory {
        let newCategory = TagCategory(name: name, tags: tags)
        metadata.tagCategories.append(newCategory)
        try saveMetadata()
        return newCategory
    }
    
    // 更新标签类别
    func updateTagCategory(id: UUID, newName: String, newTags: [String]? = nil) throws {
        if let index = metadata.tagCategories.firstIndex(where: { $0.id == id }) {
            metadata.tagCategories[index].name = newName
            
            if let tags = newTags {
                metadata.tagCategories[index].tags = tags
            }
            
            try saveMetadata()
        }
    }
    
    // 添加标签到类别
    func addTagToCategory(categoryId: UUID, tag: String) throws {
        if let index = metadata.tagCategories.firstIndex(where: { $0.id == categoryId }) {
            if !metadata.tagCategories[index].tags.contains(tag) {
                metadata.tagCategories[index].tags.append(tag)
                try saveMetadata()
            }
        }
    }
    
    // 删除标签类别
    func deleteTagCategory(id: UUID) throws {
        metadata.tagCategories.removeAll { $0.id == id }
        try saveMetadata()
    }
    
    // 添加标签到数据文件
    func addTagToDataFile(fileId: UUID, tag: String) throws {
        if let index = metadata.dataFiles.firstIndex(where: { $0.id == fileId }) {
            if !metadata.dataFiles[index].tags.contains(tag) {
                metadata.dataFiles[index].tags.append(tag)
                try saveMetadata()
            }
        }
    }
    
    // 从数据文件中移除标签
    func removeTagFromDataFile(fileId: UUID, tag: String) throws {
        if let index = metadata.dataFiles.firstIndex(where: { $0.id == fileId }) {
            metadata.dataFiles[index].tags.removeAll { $0 == tag }
            try saveMetadata()
        }
    }
}
