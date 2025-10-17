<!--
Sync Impact Report:
Version change: 0.0.0 → 1.0.0
Modified principles: All principles newly defined
Added sections: Platform Support, API Fidelity, Development Constraints
Removed sections: None (initial version)
Templates requiring updates:
✅ Updated: constitution.md
✅ Updated: plan-template.md
✅ Updated: spec-template.md
✅ Updated: tasks-template.md
Follow-up TODOs: None - all templates aligned with new principles
-->

# Chaoxing Flutter Constitution

## Core Principles

### I. Complete Feature Replication (NON-NEGOTIABLE)
所有功能必须完全复刻 chaoxing_py 项目，不允许出现模拟 API 或额外功能。每个功能模块必须与原始 Python 实现保持功能对等性，包括但不限于：登录认证、课程获取、视频学习、文档阅读、章节检测、题库答题、通知推送等核心功能。

### II. Multi-Platform Support
项目必须同时支持移动端（Android/iOS）和 Windows 桌面端。所有核心功能在所有平台上必须保持一致的用户体验和功能完整性，不允许平台特定的功能缺失。

### III. API Fidelity
严格遵循 chaoxing_py 项目的 API 调用逻辑和数据处理方式。不允许使用模拟数据或简化实现，必须使用真实的超星学习通 API 接口，保持与原始项目相同的网络请求、数据解析和业务逻辑。

### IV. UI-Only Enhancement
除了用户界面部分，不允许添加任何额外功能。所有业务逻辑、数据处理、网络通信必须与 chaoxing_py 项目保持一致。UI 层仅作为用户交互的入口，不承担业务逻辑处理职责。

### V. Test-Driven Development
采用测试驱动开发模式：测试用例编写 → 用户确认 → 测试失败 → 实现功能。每个功能模块必须包含完整的单元测试和集成测试，确保功能复制的准确性。

## Platform Support

### Mobile Platforms
- **Android**: 支持 Android 8.0+ (API Level 26+)
- **iOS**: 支持 iOS 12.0+
- **功能要求**: 完整的课程学习、视频播放、文档阅读、答题功能
- **性能要求**: 流畅的视频播放体验，响应时间 < 2秒

### Desktop Platform
- **Windows**: 支持 Windows 10+
- **功能要求**: 与移动端功能完全一致
- **性能要求**: 支持多窗口操作，内存使用优化

## Development Constraints

### Technology Stack
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **Architecture**: 分层架构（UI层、业务逻辑层、数据层）
- **状态管理**: Provider/Riverpod
- **网络请求**: Dio/HTTP
- **本地存储**: SharedPreferences/Hive

### Code Quality Standards
- **代码覆盖率**: 单元测试覆盖率 ≥ 80%
- **性能指标**: 应用启动时间 < 3秒，页面切换 < 1秒
- **内存管理**: 避免内存泄漏，及时释放资源
- **错误处理**: 完善的异常捕获和用户友好的错误提示

### Security Requirements
- **数据安全**: 用户凭据本地加密存储
- **网络安全**: HTTPS 通信，证书验证
- **隐私保护**: 不收集用户个人数据，遵循最小权限原则

## Governance

本宪法优先于所有其他开发实践和规范。任何修改都需要文档记录、团队批准和迁移计划。

**合规要求**: 所有代码审查必须验证是否符合宪法原则；任何复杂性增加都必须有明确理由；使用本宪法作为运行时开发指导。

**版本管理**: 遵循语义化版本控制（MAJOR.MINOR.PATCH），重大功能变更需要宪法修订。

**Version**: 1.0.0 | **Ratified**: 2025-01-27 | **Last Amended**: 2025-01-27
