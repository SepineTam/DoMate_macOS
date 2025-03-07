//
//  DataFileTagsView.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import UniformTypeIdentifiers

struct DataFileTagsView: View {
    // 项目URL
    var projectURL: URL
    
    // 项目数据管理器
    @State private var dataManager: ProjectDataManager
    
    // 状态变量
    @State private var dataFiles: [DataFileMetadata] = []
    @State private var isAddingFile = false
    @State private var editingFile: DataFileMetadata?
    @State private var selectedTags: Set<String> = []
    @State private var searchText = ""
    @State private var showTagsOnly = false
    
    // 用于管理标签
    @State private var isManagingTags = false
    
    // 初始化
    init(projectURL: URL) {
        self.projectURL = projectURL
        self._dataManager = State(initialValue: ProjectDataManager(projectURL: projectURL))
    }
    
    // 过滤后的数据文件
    private var filteredDataFiles: [DataFileMetadata] {
        var result = dataFiles
        
        // 标签过滤
        if !selectedTags.isEmpty {
            result = result.filter { file in
                for tag in selectedTags {
                    if file.tags.contains(tag) {
                        return true
                    }
                }
                return false
            }
        }
        
        // 搜索文本过滤
        if !searchText.isEmpty {
            result = result.filter { file in
                file.label.localizedCaseInsensitiveContains(searchText) ||
                file.path.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            // 顶部搜索和工具栏
            HStack {
                TextField("搜索数据文件...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    isManagingTags = true
                }) {
                    Label("管理标签", systemImage: "tag")
                }
                
                Button(action: {
                    isAddingFile = true
                }) {
                    Label("添加", systemImage: "plus")
                }
            }
            .padding()
            
            // 标签选择器
            if !dataManager.getAllTags().isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(dataManager.getAllTags(), id: \.self) { tag in
                            TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                toggleTag(tag)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }
            
            Divider()
            
            // 数据文件列表
            if filteredDataFiles.isEmpty {
                VStack {
                    Spacer()
                    
                    if dataFiles.isEmpty {
                        Text("暂无数据文件标签")
                            .foregroundColor(.secondary)
                        Text("点击右上角的\"添加\"按钮来添加数据文件标签")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    } else if !selectedTags.isEmpty {
                        Text("没有匹配所选标签的数据文件")
                            .foregroundColor(.secondary)
                        Button("清除标签选择") {
                            selectedTags.removeAll()
                        }
                        .padding(.top, 5)
                    } else if !searchText.isEmpty {
                        Text("没有匹配搜索条件的数据文件")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredDataFiles) { file in
                        DataFileRow(file: file, onEdit: {
                            editingFile = file
                        }, onTagTap: { tag in
                            toggleTag(tag)
                        })
                    }
                    .onDelete(perform: deleteFiles)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            refreshData()
        }
        // 添加文件对话框
        .sheet(isPresented: $isAddingFile) {
            DataFileAddView(projectURL: projectURL, allTags: dataManager.getAllTags()) { label, path, tags in
                addDataFile(label: label, path: path, tags: tags)
                isAddingFile = false
            }
        }
        // 编辑文件对话框
        .sheet(item: $editingFile) { file in
            DataFileEditView(
                label: file.label,
                path: file.path,
                tags: file.tags,
                allTags: dataManager.getAllTags()
            ) { newLabel, newPath, newTags in
                updateDataFile(file: file, newLabel: newLabel, newPath: newPath, newTags: newTags)
                editingFile = nil
            }
        }
        // 管理标签对话框
        .sheet(isPresented: $isManagingTags) {
            TagManagementView(dataManager: dataManager) {
                refreshData()
            }
        }
    }
    
    // 刷新数据
    private func refreshData() {
        dataFiles = dataManager.getAllDataFiles()
    }
    
    // 切换标签选择
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // 添加数据文件
    private func addDataFile(label: String, path: String, tags: [String]) {
        do {
            try dataManager.addDataFile(label: label, path: path, tags: tags)
            refreshData()
        } catch {
            print("添加数据文件失败: \(error.localizedDescription)")
        }
    }
    
    // 更新数据文件
    private func updateDataFile(file: DataFileMetadata, newLabel: String, newPath: String, newTags: [String]) {
        do {
            try dataManager.updateDataFile(id: file.id, newLabel: newLabel, newPath: newPath, newTags: newTags)
            refreshData()
        } catch {
            print("更新数据文件失败: \(error.localizedDescription)")
        }
    }
    
    // 删除数据文件
    private func deleteFiles(at offsets: IndexSet) {
        let filesToDelete = offsets.map { filteredDataFiles[$0] }
        
        for file in filesToDelete {
            do {
                try dataManager.deleteDataFile(id: file.id)
            } catch {
                print("删除数据文件失败: \(error.localizedDescription)")
            }
        }
        
        refreshData()
    }
}

// 标签按钮
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 数据文件行视图
struct DataFileRow: View {
    let file: DataFileMetadata
    let onEdit: () -> Void
    let onTagTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
                    Text(file.label)
                        .font(.headline)
                    Text(file.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            if !file.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(file.tags, id: \.self) { tag in
                            TagButton(tag: tag, isSelected: false) {
                                onTagTap(tag)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// 添加数据文件视图
struct DataFileAddView: View {
    var projectURL: URL
    var allTags: [String]
    var onAdd: (String, String, [String]) -> Void
    
    @State private var label = ""
    @State private var selectedURL: URL?
    @State private var selectedTags: Set<String> = []
    @State private var newTag = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("添加数据文件标签")
                .font(.headline)
                .padding(.top)
            
            TextField("数据标签", text: $label)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            
            HStack {
                Button("选择数据文件") {
                    selectDataFile()
                }
                .padding(.trailing)
                
                Text(selectedURL?.lastPathComponent ?? "未选择文件")
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 200, alignment: .leading)
            }
            
            VStack(alignment: .leading) {
                Text("标签")
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    TextField("添加标签", text: $newTag, onCommit: addCurrentTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addCurrentTag) {
                        Text("添加")
                    }
                    .disabled(newTag.isEmpty)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        if !allTags.isEmpty {
                            Text("现有标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            FlowLayout(spacing: 5) {
                                ForEach(allTags, id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                        
                        if !selectedTags.isEmpty {
                            Text("已选标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            FlowLayout(spacing: 5) {
                                ForEach(Array(selectedTags), id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: true) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 100)
            }
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Button("添加") {
                    if let url = selectedURL {
                        onAdd(label, url.path, Array(selectedTags))
                    }
                }
                .disabled(label.isEmpty || selectedURL == nil)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 400)
    }
    
    // 选择数据文件
    private func selectDataFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "dta")!]
        
        if panel.runModal() == .OK, let url = panel.url {
            selectedURL = url
            // 如果标签为空，默认使用文件名作为标签
            if label.isEmpty {
                label = url.deletingPathExtension().lastPathComponent
            }
        }
    }
    
    // 切换标签
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // 添加当前标签
    private func addCurrentTag() {
        guard !newTag.isEmpty else { return }
        selectedTags.insert(newTag)
        newTag = ""
    }
}

// 编辑数据文件视图
struct DataFileEditView: View {
    var label: String
    var path: String
    var tags: [String]
    var allTags: [String]
    var onSave: (String, String, [String]) -> Void
    
    @State private var editedLabel: String = ""
    @State private var editedPath: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var selectedURL: URL?
    @State private var newTag = ""
    @Environment(\.dismiss) private var dismiss
    
    init(label: String, path: String, tags: [String], allTags: [String], onSave: @escaping (String, String, [String]) -> Void) {
        self.label = label
        self.path = path
        self.tags = tags
        self.allTags = allTags
        self.onSave = onSave
        self._editedLabel = State(initialValue: label)
        self._editedPath = State(initialValue: path)
        self._selectedTags = State(initialValue: Set(tags))
        self._selectedURL = State(initialValue: URL(fileURLWithPath: path))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("编辑数据文件标签")
                .font(.headline)
                .padding(.top)
            
            TextField("数据标签", text: $editedLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            
            HStack {
                Button("更改数据文件") {
                    selectDataFile()
                }
                .padding(.trailing)
                
                Text(selectedURL?.lastPathComponent ?? editedPath)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 200, alignment: .leading)
            }
            
            VStack(alignment: .leading) {
                Text("标签")
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    TextField("添加标签", text: $newTag, onCommit: addCurrentTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addCurrentTag) {
                        Text("添加")
                    }
                    .disabled(newTag.isEmpty)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        if !allTags.isEmpty {
                            Text("现有标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            FlowLayout(spacing: 5) {
                                ForEach(allTags, id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                        
                        if !selectedTags.isEmpty {
                            Text("已选标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            FlowLayout(spacing: 5) {
                                ForEach(Array(selectedTags), id: \.self) { tag in
                                    TagButton(tag: tag, isSelected: true) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 100)
            }
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Button("保存") {
                    if selectedURL != nil {
                        onSave(editedLabel, selectedURL!.path, Array(selectedTags))
                    } else {
                        onSave(editedLabel, editedPath, Array(selectedTags))
                    }
                }
                .disabled(editedLabel.isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 400)
    }
    
    // 选择数据文件
    private func selectDataFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "dta")!]
        
        if panel.runModal() == .OK, let url = panel.url {
            selectedURL = url
            editedPath = url.path
        }
    }
    
    // 切换标签
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // 添加当前标签
    private func addCurrentTag() {
        guard !newTag.isEmpty else { return }
        selectedTags.insert(newTag)
        newTag = ""
    }
}

// 标签管理视图
struct TagManagementView: View {
    var dataManager: ProjectDataManager
    var onDismiss: () -> Void
    
    @State private var categories: [TagCategory] = []
    @State private var newCategoryName = ""
    @State private var editingCategory: TagCategory?
    @State private var newTagForCategory = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("标签管理")
                .font(.title)
                .padding()
            
            HStack {
                TextField("新类别名称", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("添加类别") {
                    addCategory()
                }
                .disabled(newCategoryName.isEmpty)
            }
            .padding(.horizontal)
            
            List {
                ForEach(categories) { category in
                    DisclosureGroup(category.name) {
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("新标签", text: $newTagForCategory)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("添加") {
                                    addTagToCategory(category)
                                }
                                .disabled(newTagForCategory.isEmpty)
                            }
                            
                            if !category.tags.isEmpty {
                                FlowLayout(spacing: 5) {
                                    ForEach(category.tags, id: \.self) { tag in
                                        TagButton(tag: tag, isSelected: false) {
                                            // 预览标签，无实际操作
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Button("重命名类别") {
                                    editingCategory = category
                                }
                                
                                Button("删除类别") {
                                    deleteCategory(category)
                                }
                                .foregroundColor(.red)
                            }
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button("完成") {
                    dismiss()
                    onDismiss()
                }
                .padding()
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            refreshCategories()
        }
        .sheet(item: $editingCategory) { category in
            RenameTagCategoryView(categoryName: category.name) { newName in
                renameCategory(category, newName: newName)
                editingCategory = nil
            }
        }
    }
    
    // 刷新类别
    private func refreshCategories() {
        categories = dataManager.getAllTagCategories()
    }
    
    // 添加类别
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        do {
            try dataManager.addTagCategory(name: newCategoryName)
            newCategoryName = ""
            refreshCategories()
        } catch {
            print("添加标签类别失败: \(error.localizedDescription)")
        }
    }
    
    // 重命名类别
    private func renameCategory(_ category: TagCategory, newName: String) {
        do {
            try dataManager.updateTagCategory(id: category.id, newName: newName)
            refreshCategories()
        } catch {
            print("重命名标签类别失败: \(error.localizedDescription)")
        }
    }
    
    // 删除类别
    private func deleteCategory(_ category: TagCategory) {
        do {
            try dataManager.deleteTagCategory(id: category.id)
            refreshCategories()
        } catch {
            print("删除标签类别失败: \(error.localizedDescription)")
        }
    }
    
    // 添加标签到类别
    private func addTagToCategory(_ category: TagCategory) {
        guard !newTagForCategory.isEmpty else { return }
        
        do {
            try dataManager.addTagToCategory(categoryId: category.id, tag: newTagForCategory)
            newTagForCategory = ""
            refreshCategories()
        } catch {
            print("添加标签到类别失败: \(error.localizedDescription)")
        }
    }
}

// 重命名标签类别视图
struct RenameTagCategoryView: View {
    var categoryName: String
    var onRename: (String) -> Void
    
    @State private var newName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    init(categoryName: String, onRename: @escaping (String) -> Void) {
        self.categoryName = categoryName
        self.onRename = onRename
        self._newName = State(initialValue: categoryName)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("重命名标签类别")
                .font(.headline)
                .padding(.top)
            
            TextField("类别名称", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Button("保存") {
                    onRename(newName)
                    dismiss()
                }
                .disabled(newName.isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 150)
    }
}

// 流布局辅助视图，用于灵活展示标签
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 10) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidth + size.width + spacing > maxWidth {
                // 换行
                width = max(width, lineWidth - spacing)
                height += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        // 处理最后一行
        width = max(width, lineWidth - spacing)
        height += lineHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineOrigin = bounds.origin
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidth + size.width + spacing > maxWidth {
                // 换行
                lineOrigin.y += lineHeight + spacing
                lineOrigin.x = bounds.origin.x
                lineWidth = 0
                lineHeight = 0
            }
            
            let point = CGPoint(x: lineOrigin.x + lineWidth, y: lineOrigin.y)
            subview.place(at: point, proposal: .unspecified)
            
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
