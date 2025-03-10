# DoMate

<div align="center">
    <img src="https://via.placeholder.com/200x200.png?text=DoMate" alt="DoMate Logo" width="200"/>
    <h3>Stata do文件管理工具</h3>
</div>

## 项目概述

DoMate 是一款专为 Stata 用户设计的 macOS 应用程序，旨在提供一个高效的 do 文件管理和编辑环境。通过 DoMate，用户可以更便捷地组织、标记和编辑 Stata do 文件，同时提供数据文件的引用管理和代码段的标签管理功能。

## 主要功能

- **项目管理**：创建和管理 .domt 项目文件夹，方便组织相关 do 文件和数据
- **数据文件标签**：为 dta 数据文件创建标签，方便在 do 文件中引用
- **函数标签模板**：定义和管理代码段标签模板，方便在 do 文件中标记和组织代码
- **do 文件编辑**：内置编辑器，支持语法突出显示和代码段插入
- **数据引用插入**：在编辑 do 文件时可直接插入已标记的数据文件引用
- **最近项目记录**：自动记录最近打开的项目，方便快速访问

## 系统要求

- macOS 12.0 或更高版本
- 支持 Apple Silicon 和 Intel 处理器
- 至少 100MB 可用存储空间

## 安装

1. 下载最新版本的 DoMate.dmg 文件
2. 打开 DMG 文件，将 DoMate 应用拖拽到应用程序文件夹
3. 从应用程序文件夹或 Launchpad 启动 DoMate

## 使用方法

### 创建新项目

1. 启动 DoMate 应用
2. 在欢迎界面点击"新建项目"
3. 输入项目名称，选择保存位置
4. 点击"创建"完成项目创建

项目将被创建为带有 .domt 扩展名的文件夹，包含必要的项目元数据文件。

### 管理数据文件标签

1. 在项目中，进入"数据文件"标签页
2. 点击"添加数据文件"选择 .dta 文件
3. 为数据文件设置一个便于记忆的标签
4. 标签将被保存，便于在 do 文件中引用

### 创建和管理标签模板

1. 在"标签模板"标签页中，可以查看、添加和管理标签模板
2. 默认提供"** Function: $label$_begin**"和"** Function: $label$_end**"格式
3. 可以创建自定义模板，使用 $label$ 作为内容标签的占位符

### 编辑 do 文件

1. 打开或创建一个 do 文件
2. 使用内置编辑器编辑文件内容
3. 使用底部工具栏插入数据引用或函数标签
4. 对于数据引用，从下拉菜单中选择已标记的数据文件
5. 对于函数标签，输入标签内容并点击"插入函数标签"

## 技术架构

DoMate 使用以下技术构建：

- **SwiftUI**：用于构建现代化、响应式用户界面
- **SwiftData**：用于本地数据持久化和管理
- **Combine**：用于处理异步事件和数据流
- **FileDocument**：用于文档管理和编辑功能

## 未来计划

- 添加 Stata 语法高亮支持
- 实现代码段库功能
- 添加项目级变量管理
- 支持多文档标签页界面
- 增加团队协作功能
- 添加导出和共享功能

## 开发者信息

DoMate 由 SepineTam 开发，旨在提升 Stata 用户的工作效率和代码组织能力。

## 许可证

©2025 SepineTam. 保留所有权利。
