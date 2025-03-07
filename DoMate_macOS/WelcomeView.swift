//
//  WelcomeView.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import UniformTypeIdentifiers

struct WelcomeView: View {
    @State private var isCreatingProject = false
    @State private var isOpeningProject = false
    @State private var newProjectName = ""
    @State private var selectedPath: String?
    
    // 用于传递选中或创建的项目路径
    var onProjectSelected: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // 顶部标志和标题
            VStack(spacing: 15) {
                Image(systemName: "doc.text.magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("欢迎使用 DoMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Stata do文件管理工具")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Divider()
                .padding(.horizontal, 40)
            
            // 操作按钮
            HStack(spacing: 40) {
                // 打开项目按钮
                VStack {
                    Button(action: {
                        isOpeningProject = true
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "folder.badge.plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            
                            Text("打开项目")
                                .font(.headline)
                        }
                        .frame(width: 150, height: 150)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("打开现有的.domt项目文件夹")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 创建项目按钮
                VStack {
                    Button(action: {
                        isCreatingProject = true
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "folder.fill.badge.plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            
                            Text("新建项目")
                                .font(.headline)
                        }
                        .frame(width: 150, height: 150)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("创建新的.domt项目文件夹")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 底部版权信息
            Text("DoMate v1.0 © 2025 SepineTam")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .frame(minWidth: 600, minHeight: 400)
        .padding()
        // 文件夹选择器
        .fileImporter(
            isPresented: $isOpeningProject,
            allowedContentTypes: [UTType.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedURL = urls.first {
                    // 检查是否是.domt文件夹
                    if selectedURL.pathExtension == "domt" {
                        onProjectSelected(selectedURL)
                    } else {
                        // 弹出警告：不是.domt文件夹
                        showInvalidFolderAlert()
                    }
                }
            case .failure(let error):
                print("文件选择错误: \(error.localizedDescription)")
            }
        }
        // 创建项目对话框
        .sheet(isPresented: $isCreatingProject) {
            VStack(spacing: 20) {
                Text("创建新项目")
                    .font(.headline)
                    .padding(.top)
                
                TextField("项目名称", text: $newProjectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
                
                HStack {
                    Button("选择位置") {
                        selectFolderLocation()
                    }
                    .padding(.trailing)
                    
                    Text(selectedPath ?? "未选择位置")
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(width: 200, alignment: .leading)
                }
                
                HStack {
                    Button("取消") {
                        isCreatingProject = false
                        resetProjectCreation()
                    }
                    
                    Spacer()
                    
                    Button("创建") {
                        createNewProject()
                    }
                    .disabled(newProjectName.isEmpty || selectedPath == nil)
                }
                .padding(.top)
            }
            .padding()
            .frame(width: 400, height: 200)
        }
    }
    
    // 选择项目创建位置
    private func selectFolderLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            selectedPath = panel.url?.path
        }
    }
    
    // 创建新项目
    private func createNewProject() {
        guard !newProjectName.isEmpty, let basePath = selectedPath else { return }
        
        // 确保项目名称有.domt扩展名
        var projectName = newProjectName
        if !projectName.hasSuffix(".domt") {
            projectName += ".domt"
        }
        
        let projectPath = URL(fileURLWithPath: basePath).appendingPathComponent(projectName)
        
        do {
            try FileManager.default.createDirectory(at: projectPath, withIntermediateDirectories: true)
            
            // 创建项目元数据文件
            let metadataFile = projectPath.appendingPathComponent("project.json")
            let metadata: [String: Any] = [
                "name": projectName.replacingOccurrences(of: ".domt", with: ""),
                "created_date": Date().timeIntervalSince1970,
                "creator": "DoMate_macOS"
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: metadata) {
                try jsonData.write(to: metadataFile)
            }
            
            isCreatingProject = false
            resetProjectCreation()
            
            // 通知项目已创建
            onProjectSelected(projectPath)
            
        } catch {
            print("创建项目失败: \(error.localizedDescription)")
            // 在实际应用中应该向用户显示错误信息
        }
    }
    
    // 重置项目创建状态
    private func resetProjectCreation() {
        newProjectName = ""
        selectedPath = nil
    }
    
    // 显示无效文件夹警告
    private func showInvalidFolderAlert() {
        let alert = NSAlert()
        alert.messageText = "无效的项目文件夹"
        alert.informativeText = "请选择扩展名为.domt的文件夹。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}
