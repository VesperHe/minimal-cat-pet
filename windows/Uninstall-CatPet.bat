@echo off
setlocal
chcp 65001 >nul
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\MinimalCatPet"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$desktopLink=Join-Path ([Environment]::GetFolderPath('Desktop')) '猫咪桌宠.lnk'; $startupLink=Join-Path ([Environment]::GetFolderPath('Startup')) '猫咪桌宠.lnk'; Remove-Item -LiteralPath $desktopLink,$startupLink -Force -ErrorAction SilentlyContinue"

echo 请先右键猫咪并选择“关闭这只猫咪”。
echo 程序文件将被移除。
pause

start "" powershell.exe -NoLogo -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Remove-Item -LiteralPath '%INSTALL_DIR%' -Recurse -Force -ErrorAction SilentlyContinue"
exit /b 0
