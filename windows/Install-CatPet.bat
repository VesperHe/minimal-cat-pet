@echo off
setlocal
chcp 65001 >nul
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\MinimalCatPet"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
xcopy "%~dp0*" "%INSTALL_DIR%\" /E /I /Y /Q >nul

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$desktop=[Environment]::GetFolderPath('Desktop'); $shell=New-Object -ComObject WScript.Shell; $link=$shell.CreateShortcut((Join-Path $desktop '猫咪桌宠.lnk')); $link.TargetPath='%INSTALL_DIR%\Start-CatPet.bat'; $link.WorkingDirectory='%INSTALL_DIR%'; $link.Description='猫咪桌宠'; $link.Save()"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-ChildItem -LiteralPath '%INSTALL_DIR%' -Recurse -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue"

start "" "%INSTALL_DIR%\Start-CatPet.bat"
echo.
echo 安装完成。桌面已经创建“猫咪桌宠”快捷方式。
pause
endlocal
