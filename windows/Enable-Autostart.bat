@echo off
setlocal
chcp 65001 >nul
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\MinimalCatPet"

if not exist "%INSTALL_DIR%\Start-CatPet.bat" (
  echo 请先运行 Install-CatPet.bat 完成安装。
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$startup=[Environment]::GetFolderPath('Startup'); $shell=New-Object -ComObject WScript.Shell; $link=$shell.CreateShortcut((Join-Path $startup '猫咪桌宠.lnk')); $link.TargetPath='%INSTALL_DIR%\Start-CatPet.bat'; $link.WorkingDirectory='%INSTALL_DIR%'; $link.Description='猫咪桌宠开机启动'; $link.Save()"

echo 已设置为登录 Windows 后自动启动。
pause
endlocal
