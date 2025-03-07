//
//  ProjectView.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import SwiftData

struct ProjectView: View {
    let projectURL: URL
    let onClose: () -> Void
    
    @State private var selectedTab = 0
    @State private var dataManager: ProjectDataManager
    
    init(projectURL: URL, onClose: @escaping () -> Void) {
        self.projectURL = projectURL
        self.onClose = onClose
        self._dataManager = State(initialValue: ProjectDataManager(projectURL: projectURL))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("项目：\(projectURL.lastPathComponent)")
                    .font(.headline)
                
                Spacer()
                
                Button("关闭项目") {
                    onClose()
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // 选项卡栏
            HStack(spacing: 20) {
                TabButton(title: "概览", systemImage: "doc.text", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "数据文件", systemImage: "folder.badge.gearshape", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "标签模板", systemImage: "tag", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // 内容区域
            ZStack {
                // 概览选项卡
                if selectedTab == 0 {
                    ProjectOverviewView(projectURL: projectURL, dataManager: dataManager)
                        .transition(.opacity)
                }
                
                // 数据文件选项卡
                if selectedTab == 1 {
                    DataFileTagsView(projectURL: projectURL)
                        .transition(.opacity)
                }
                
                // 标签模板选项卡
                if selectedTab == 2 {
                    Text("标签模板功能即将推出...")
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// 选项卡按钮
struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14))
            }
            .foregroundColor(isSelected ? .accentColor : .primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 项目概览视图
struct ProjectOverviewView: View {
    let projectURL: URL
    let dataManager: ProjectDataManager
    
    @State private var dataCount = 0
    @State private var tagCount = 0
    
    var body: some View {
        VStack {
            // 显示项目的基本信息和统计数据
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("项目信息")
                        .font(.headline)
                    
                    HStack {
                        Text("位置:")
                        Text(projectURL.deletingLastPathComponent().path)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("文件夹名称:")
                        Text(projectURL.lastPathComponent)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.windowBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("项目统计")
                        .font(.headline)
                    
                    HStack {
                        Text("数据文件数量:")
                        Text("\(dataCount)")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("标签数量:")
                        Text("\(tagCount)")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.windowBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            }
            .padding()
            
            // 快速操作区
            VStack(alignment: .leading, spacing: 10) {
                Text("快速操作")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Button(action: {
                        // 打开项目文件夹
                        NSWorkspace.shared.open(projectURL)
                    }) {
                        VStack {
                            Image(systemName: "folder")
                                .font(.system(size: 30))
                                .padding(.bottom, 5)
                            Text("在Finder中显示")
                                .font(.caption)
                        }
                        .frame(width: 120, height: 80)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // 创建新do文件
                        // 这个功能将在后续实现
                    }) {
                        VStack {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 30))
                                .padding(.bottom, 5)
                            Text("创建新do文件")
                                .font(.caption)
                        }
                        .frame(width: 120, height: 80)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // 打开数据文件标签页
                        // 在实际应用中这应该切换到数据文件标签页
                    }) {
                        VStack {
                            Image(systemName: "tag")
                                .font(.system(size: 30))
                                .padding(.bottom, 5)
                            Text("管理数据标签")
                                .font(.caption)
                        }
                        .frame(width: 120, height: 80)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .padding()
            
            Spacer()
            
            Text("DoMate 致力于帮助您更高效地管理Stata分析项目")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .onAppear {
            updateStats()
        }
    }
    
    // 更新统计数据
    private func updateStats() {
        dataCount = dataManager.getAllDataFiles().count
        tagCount = dataManager.getAllTags().count
    }
}
