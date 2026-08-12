@echo off
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$link=Join-Path ([Environment]::GetFolderPath('Startup')) '猫咪桌宠.lnk'; Remove-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue"
echo 已取消开机启动。
pause
