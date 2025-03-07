//
//  DoMateApp.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers // 添加这个导入，解决UTType问题

@main
struct DoMateApp: App {
    // 创建共享的模型容器
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            DataFile.self,
            TagTemplate.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // 状态管理
    @State private var currentProjectURL: URL?
    @State private var shouldShowWelcomeView = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowWelcomeView {
                    WelcomeView { selectedProjectURL in
                        // 处理项目选择
                        self.currentProjectURL = selectedProjectURL
                        self.shouldShowWelcomeView = false
                        
                        // 保存项目到最近打开记录
                        saveProjectToRecents(url: selectedProjectURL)
                    }
                } else {
                    if let projectURL = currentProjectURL {
                        ProjectView(projectURL: projectURL) {
                            // 关闭项目回调
                            self.shouldShowWelcomeView = true
                            self.currentProjectURL = nil
                        }
                    } else {
                        // 这种情况理论上不应该发生
                        Text("错误：无法加载项目")
                            .onAppear {
                                self.shouldShowWelcomeView = true
                            }
                    }
                }
            }
            .modelContainer(sharedModelContainer)
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建项目") {
                    // 显示欢迎界面以创建新项目
                    self.shouldShowWelcomeView = true
                }
                
                Button("打开项目...") {
                    openExistingProject()
                }
                
                Divider()
                
                Menu("最近打开的项目") {
                    // 这里将来可以列出最近打开的项目
                    ForEach(getRecentProjects(), id: \.path) { project in
                        Button(project.name) {
                            openProjectFromRecents(project: project)
                        }
                    }
                }
            }
        }
        
        // 文档场景 - 处理do文件
        DocumentGroup(newDocument: DoDocument()) { file in
            if let projectURL = currentProjectURL {
                DoEditorView(document: file.$document, projectURL: projectURL)
                    .modelContainer(sharedModelContainer)
            } else {
                DoEditorView(document: file.$document, projectURL: nil)
                    .modelContainer(sharedModelContainer)
            }
        }
    }
    
    // 打开现有项目
    private func openExistingProject() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType.folder]
        
        if panel.runModal() == .OK, let url = panel.url {
            // 检查是否是.domt文件夹
            if url.pathExtension == "domt" {
                currentProjectURL = url
                shouldShowWelcomeView = false
                saveProjectToRecents(url: url)
            } else {
                // 显示错误：不是.domt文件夹
                let alert = NSAlert()
                alert.messageText = "无效的项目文件夹"
                alert.informativeText = "请选择扩展名为.domt的文件夹。"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "确定")
                alert.runModal()
            }
        }
    }
    
    // 保存项目到最近打开记录
    private func saveProjectToRecents(url: URL) {
        let modelContext = sharedModelContainer.mainContext
        
        // 检查项目是否已存在
        let projectPath = url.path
        let fetchDescriptor = FetchDescriptor<Project>(
            predicate: #Predicate<Project> { project in
                project.path == projectPath
            }
        )
        
        do {
            let existingProjects = try modelContext.fetch(fetchDescriptor)
            
            if let existingProject = existingProjects.first {
                // 更新现有项目
                existingProject.lastOpened = Date()
            } else {
                // 创建新项目记录
                let folderName = url.lastPathComponent.replacingOccurrences(of: ".domt", with: "")
                let newProject = Project(name: folderName, path: projectPath)
                modelContext.insert(newProject)
            }
            
            try modelContext.save()
        } catch {
            print("保存项目到最近打开记录失败: \(error.localizedDescription)")
        }
    }
    
    // 获取最近打开的项目
    private func getRecentProjects() -> [Project] {
        let modelContext = sharedModelContainer.mainContext
        // 使用var而不是let，因为我们需要设置fetchLimit
        var fetchDescriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.lastOpened, order: .reverse)]
        )
        fetchDescriptor.fetchLimit = 10  // 最多显示10个最近项目
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("获取最近项目失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // 从最近打开记录中打开项目
    private func openProjectFromRecents(project: Project) {
        let projectPath = project.path
        let url = URL(fileURLWithPath: projectPath)
        
        // 检查项目文件夹是否存在
        if FileManager.default.fileExists(atPath: projectPath) {
            currentProjectURL = url
            shouldShowWelcomeView = false
            
            // 更新最后打开时间
            let modelContext = sharedModelContainer.mainContext
            project.lastOpened = Date()
            try? modelContext.save()
        } else {
            // 显示错误：项目不存在
            let alert = NSAlert()
            alert.messageText = "项目不存在"
            alert.informativeText = "无法找到项目文件夹：\(projectPath)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
            
            // 从记录中删除不存在的项目
            let modelContext = sharedModelContainer.mainContext
            modelContext.delete(project)
            try? modelContext.save()
        }
    }
}

// 这是项目视图的占位符，您可以根据需要扩展它
struct ProjectView: View {
    let projectURL: URL
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("项目：\(projectURL.lastPathComponent)")
                    .font(.title)
                
                Spacer()
                
                Button("关闭项目") {
                    onClose()
                }
            }
            .padding()
            
            Text("项目内容将在这里显示")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
