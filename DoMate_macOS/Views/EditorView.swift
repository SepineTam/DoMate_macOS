//
//  EditorView.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import SwiftData

// do文件编辑器视图
struct DoEditorView: View {
    @Binding var document: DoDocument
    var projectURL: URL?
    
    // 模型上下文 - 用于标签模板
    @Environment(\.modelContext) private var modelContext
    @State private var selectedLabel = ""
    
    // 项目数据管理器
    @State private var dataManager: ProjectDataManager?
    
    // 数据
    @State private var tagTemplates: [TagTemplate] = []
    @State private var dataFiles: [DataFileMetadata] = []
    
    // 获取默认标签模板
    private var defaultTemplate: TagTemplate? {
        tagTemplates.first { $0.isDefault }
    }
    
    var body: some View {
        VStack {
            // 使用TextEditor显示和编辑do文件内容
            TextEditor(text: $document.text)
                .font(.system(.body, design: .monospaced))
                .padding()
            
            Divider()
            
            // 工具栏
            HStack {
                // 插入数据引用按钮
                Menu("插入数据引用") {
                    ForEach(dataFiles) { file in
                        Button(file.label) {
                            insertDataReference(file)
                        }
                    }
                }
                .disabled(dataFiles.isEmpty)
                
                Spacer()
                
                // 函数标签插入界面
                TextField("函数标签", text: $selectedLabel)
                    .frame(width: 200)
                
                Button("插入函数标签") {
                    insertFunctionTags()
                }
                .disabled(selectedLabel.isEmpty || defaultTemplate == nil)
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
    }
    
    // 加载数据
    private func loadData() {
        // 加载标签模板
        do {
            let templateDescriptor = FetchDescriptor<TagTemplate>()
            tagTemplates = try modelContext.fetch(templateDescriptor)
        } catch {
            print("加载标签模板错误: \(error)")
            tagTemplates = []
        }
        
        // 加载数据文件标签
        if let projectURL = projectURL {
            dataManager = ProjectDataManager(projectURL: projectURL)
            dataFiles = dataManager?.getAllDataFiles() ?? []
        } else {
            dataFiles = []
        }
    }
    
    // 在光标位置插入数据文件引用
    private func insertDataReference(_ file: DataFileMetadata) {
        let reference = "\nuse \"\(file.path)\"\n"
        insertAtCursor(reference)
    }
    
    // 在光标位置插入函数标签
    private func insertFunctionTags() {
        guard let template = defaultTemplate else { return }
        
        // 将$label$替换为选定的标签
        let beginTag = template.beginFormat.replacingOccurrences(of: "$label$", with: selectedLabel) + "\n"
        let endTag = "\n" + template.endFormat.replacingOccurrences(of: "$label$", with: selectedLabel)
        
        let insertion = beginTag + endTag
        insertAtCursor(insertion)
    }
    
    // 在光标位置插入文本的辅助函数
    private func insertAtCursor(_ text: String) {
        // 简化方法，仅在文档末尾添加文本
        document.text += text
    }
}
