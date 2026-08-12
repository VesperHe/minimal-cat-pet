# Windows 版本

支持 Windows 10/11 64 位，使用系统自带的 Windows PowerShell 5.1 与 WPF，不需要 Python 或管理员权限。

## 安装

1. 完整解压下载的 ZIP，不能直接在压缩包预览窗口中运行。
2. 双击 `Install-CatPet.bat`。
3. 安装器会将文件复制到 `%LOCALAPPDATA%\Programs\MinimalCatPet`，并创建桌面快捷方式。

也可以直接双击 `Start-CatPet.bat` 便携运行。

## 使用

- 左键拖动猫咪。
- 右键选择“关闭这只猫咪”。
- `Enable-Autostart.bat`：启用登录后启动。
- `Disable-Autostart.bat`：取消登录后启动。
- `Uninstall-CatPet.bat`：移除快捷方式与安装目录。

## 安全提示

程序未进行商业代码签名。如果 SmartScreen 弹出提示，请只在确认文件来自本仓库 Releases 后继续运行。启动批处理通过 `ExecutionPolicy Bypass` 运行同目录的本地脚本，不会更改系统的全局执行策略。
