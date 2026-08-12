# 审查记录

## 已检查

- macOS Swift/AppKit 窗口、动画、拖动、位置保存与关闭逻辑
- Universal 2 编译、应用包结构、Info.plist 与 ad-hoc 签名
- Windows PowerShell/WPF 窗口、动画、单实例、位置保存与异常处理
- Windows 安装、启动、开机启动、取消开机启动和卸载脚本
- 资源尺寸、透明通道、目录相对路径与压缩包完整性
- 源码中的网络访问、凭据、硬编码用户目录和遥测行为

## 本次修复

- 将 macOS Swift 模块缓存移入项目构建目录，避免沙盒或 CI 权限失败。
- 清理 macOS 中旧金色猫分支及未使用的关闭面板代码。
- 为 macOS 保存位置增加可见屏幕边界校正。
- 为 Windows 保存位置增加整个虚拟桌面的边界校正，兼容多显示器。
- 将 Windows 动画帧索引改为脚本作用域，避免事件回调作用域导致动画停在第二帧。
- 修正 Windows 卸载脚本的异步删除命令与引号处理。
- 统一 Git 行尾规则，确保 `.bat`/`.ps1` 在 Windows 上正常读取。

## 已知限制

- macOS 包使用 ad-hoc 签名，未经过 Apple notarization。
- Windows 文件未进行 Authenticode 商业签名，可能触发 SmartScreen。
- Windows GUI 无法在 macOS 本机实际启动；仓库 CI 会在 Windows runner 上解析 PowerShell 并检查文件结构。
