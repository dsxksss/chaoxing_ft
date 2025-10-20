# 超星学习通助手

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS%20%7C%20Linux%20%7C%20macOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

一个基于 Flutter 开发的跨平台超星学习通辅助工具

[功能特性](#功能特性) • [快速开始](#快速开始) • [安装包下载](#安装包下载) • [使用说明](#使用说明) • [致谢](#致谢)

</div>

---

## 📋 项目说明

**本项目实现逻辑借鉴于 [chaoxing](https://github.com/Samueli924/chaoxing) 项目，感谢该项目各个贡献者的付出。**

本项目使用 **Flutter** 框架完全重写实现，提供了一个全平台的操作 GUI 界面，方便使用者直接使用。由于是重写实现，因此与原项目在功能上会有偏差，目前只实现了刷视频部分的功能。

### ⚠️ 重要声明

- ✅ **本项目完全免费，绝无存在收费情况**
- ✅ 仅供学习交流使用，请勿用于商业用途
- ✅ 使用本工具产生的任何后果由使用者自行承担
- ✅ 请遵守相关法律法规和学校规定

---

## ✨ 功能特性

### 🎯 核心功能
- ✅ **课程管理** - 自动获取所有课程列表
- ✅ **作业任务** - 自动完成视频、文档等学习任务
- ✅ **视频学习** - 支持倍速播放（1.0x / 2.0x）
- ✅ **进度同步** - 实时显示学习进度
- ✅ **任务追踪** - 自动标记已完成任务
- ✅ **会话管理** - 自动维护登录状态

### 🎨 界面特色
- 🎯 **现代化 UI** - Material Design 风格
- 📱 **响应式布局** - 适配各种屏幕尺寸
- 🔄 **下拉刷新** - 快速更新任务列表
- 📊 **实时进度条** - 可视化任务执行进度
- 🌈 **状态指示** - 清晰的任务状态标识

### 🚀 平台支持
- ✅ Windows（EXE 安装包）
- ✅ Android（APK）

---

## 🚀 快速开始

### 环境要求

- **Flutter SDK**: 3.9.2 或更高版本
- **Dart SDK**: 3.0 或更高版本
- **开发工具**: Android Studio / VS Code

### 克隆项目

```bash
git clone https://github.com/your-username/chaoxing_ft.git
cd chaoxing_ft
```

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# Windows
flutter run -d windows

# Android
flutter run -d android
```

---

## 📦 安装包下载

- Windows (https://github.com/dsxksss/chaoxing_ft/releases/latest)
- Android (https://github.com/dsxksss/chaoxing_ft/releases/latest)

## 编译安装包

### Windows 用户 EXE 安装程序（最友好）

```bash
# 使用自动化脚本
.\build_exe_installer.bat
```

安装包位置：`build\windows\installer\ChaoxingHelper_Setup_v1.0.0.exe`

**优势**：
- ✅ 双击即可安装，无需额外配置
- ✅ 自动创建桌面和开始菜单快捷方式
- ✅ 支持完整的卸载功能


### Android 用户

```bash
flutter build apk --release
```

APK 位置：`build\app\outputs\flutter-apk\app-release.apk`

---

## 📖 使用说明

### 1️⃣ 首次启动

应用启动时会显示**项目声明对话框**，请仔细阅读后点击"我已知晓"继续。

### 2️⃣ 登录账号

- 输入超星学习通账号和密码
- 点击"登录"按钮
- 等待登录验证

### 3️⃣ 选择课程

- 在课程列表中滑动查看所有课程
- 点击课程卡片选择要学习的课程
- 选中的课程会显示蓝色勾选图标

### 4️⃣ 配置倍速

在执行任务前，可以选择播放速度：
- **1.0x** - 正常速度
- **2.0x** - 双倍速度

### 5️⃣ 执行任务

- 点击"开始执行作业"按钮
- 实时查看任务执行进度
- 等待所有任务完成

### 6️⃣ 刷新任务

- 在任务列表区域**下拉刷新**可以更新任务状态
- 已完成的任务会显示绿色勾选标记

### 7️⃣ 退出登录

- 点击左上角的**退出按钮**
- 确认退出后返回登录页面
- **安全提示**：按返回键也会弹出确认对话框

---

## 🛠️ 技术栈

### 前端框架
- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言
- **Provider** - 状态管理

### 核心依赖
- `dio` - HTTP 网络请求
- `hive` - 本地数据存储
- `shared_preferences` - 配置持久化
- `encrypt` - 加密解密
- `logger` - 日志记录
- `url_launcher` - 打开外部链接

### 打包工具
- `msix` - Windows MSIX 打包
- `Inno Setup` - Windows EXE 安装程序

---

## 📂 项目结构

```
chaoxing_ft/
├── lib/
│   ├── app/                    # 应用配置
│   │   └── routes.dart        # 路由配置
│   ├── core/                  # 核心工具类
│   │   ├── di/               # 依赖注入
│   │   ├── session/          # 会话管理
│   │   ├── crypto/           # 加密工具
│   │   └── errors/           # 错误处理
│   ├── data/                  # 数据层
│   │   ├── datasources/      # 数据源
│   │   ├── repositories/     # 仓库实现
│   │   └── models/           # 数据模型
│   ├── domain/                # 领域层
│   │   ├── entities/         # 实体
│   │   └── usecases/         # 用例
│   ├── presentation/          # 表现层
│   │   ├── pages/            # 页面
│   │   ├── widgets/          # 组件
│   │   └── providers/        # 状态管理
│   └── services/              # 业务服务
│       ├── task/             # 任务服务
│       └── video/            # 视频服务
├── android/                   # Android 配置
├── windows/                   # Windows 配置
├── ios/                       # iOS 配置
├── linux/                     # Linux 配置
├── macos/                     # macOS 配置
├── web/                       # Web 配置
└── chaoxing_py/              # Python 服务模块
```

---

## 🔧 开发指南 （由于是借助了AI开发，大部分逻辑存在严谨问题，修改难度大，酌情决定是否要提交PR）

### 提交 Issue

- 🐛 **Bug 报告**：请详细描述问题和复现步骤
- ✨ **功能建议**：说明功能需求和使用场景
- 📝 **文档改进**：指出文档中的错误或不清楚的地方

### Pull Request

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 开源协议

本项目基于 [MIT License](LICENSE) 开源。

---

## 🙏 致谢

### 灵感来源

本项目实现逻辑借鉴于 [Samueli924/chaoxing](https://github.com/Samueli924/chaoxing) 项目。

感谢该项目及其所有贡献者的付出，为本项目提供了宝贵的参考和灵感。

### 技术支持

- [Flutter](https://flutter.dev/) - Google 的 UI 工具包
- [Dart](https://dart.dev/) - 优化的客户端开发语言
- [Provider](https://pub.dev/packages/provider) - Flutter 推荐的状态管理方案

---

## 📮 联系方式

- **项目主页**: [GitHub](https://github.com/dsxksss/chaoxing_ft)
- **问题反馈**: [Issues](https://github.com/dsxksss/chaoxing_ft/issues)
- **讨论交流**: [Discussions](https://github.com/dsxksss/chaoxing_ft/discussions)

---

## ⭐ Star History

如果这个项目对你有帮助，请给一个 ⭐ Star 支持一下！

---

