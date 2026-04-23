<#
.SYNOPSIS
    RB 極致省電優化工具 (GitHub 穩定版)
    修正了權限重啟後的閃退問題。
#>

# --- 1. 自動檢查並請求管理員權限 (強化版) ---
$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentIdentity)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$IsAdmin) {
    Write-Host "正在請求管理員權限以執行系統優化..." -ForegroundColor Yellow
    # 使用引號包裹路徑，防止資料夾名稱有空格導致閃退
    $ArgList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    try {
        Start-Process powershell.exe -ArgumentList $ArgList -Verb RunAs -ErrorAction Stop
        exit
    } catch {
        Write-Host "使用者拒絕了管理員授權，腳本即將關閉。" -ForegroundColor Red
        Start-Sleep -Seconds 3
        exit
    }
}

# --- 2. 確保執行路徑正確 ---
Set-Location -Path $PSScriptRoot

# --- 3. 主選單迴圈 ---
function Show-Menu {
    Clear-Host
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "      RB 專用極簡省電工具 (v2.0)" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "1. 徹底關閉檔案總管 (桌面消失/省電)" -ForegroundColor Red
    Write-Host "2. 恢復檔案總管 (顯示桌面)" -ForegroundColor Green
    Write-Host "3. 終極優化 (CPU 鎖定 50% + 省電模式)" -ForegroundColor Yellow
    Write-Host "4. 恢復正常 (平衡模式)" -ForegroundColor Blue
    Write-Host "5. 退出"
    Write-Host "==========================================="
}

while ($true) {
    Show-Menu
    $Selection = Read-Host "請輸入選項 (1-5)"

    switch ($Selection) {
        "1" {
            Write-Host "正在停止 Explorer 自動重啟機制..." -ForegroundColor Yellow
            # 關閉自動重啟
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 0
            # 強制終止
            taskkill /f /im explorer.exe 2>$null
            Write-Host "成功：檔案總管已徹底關閉。" -ForegroundColor Green
            Pause
        }
        "2" {
            Write-Host "正在恢復 Explorer..." -ForegroundColor Yellow
            # 恢復自動重啟
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 1
            # 啟動
            start-process explorer.exe
            Write-Host "成功：檔案總管已恢復。" -ForegroundColor Green
            Pause
        }
        "3" {
            Write-Host "正在套用極限省電參數..." -ForegroundColor Yellow
            # 切換到省電模式 (Power Saver)
            powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a
            # 限制插電與電池狀態下的 CPU 上限
            powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 50
            powercfg /setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 50
            powercfg /setactive scheme_current
            Write-Host "成功：CPU 已鎖定 50% 功耗。" -ForegroundColor Green
            Pause
        }
        "4" {
            Write-Host "正在恢復平衡模式..." -ForegroundColor Cyan
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            Write-Host "成功：已切換回系統預設狀態。" -ForegroundColor Green
            Pause
        }
        "5" { 
            # 安全退出：確保系統設定被重設回預設
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 1
            exit 
        }
        default { 
            Write-Host "錯誤：無效的選項！" -ForegroundColor Red
            Start-Sleep -Seconds 1 
        }
    }
}
