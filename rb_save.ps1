<#
.SYNOPSIS
    RB 極致省電優化工具 (PowerShell 專業版)
    功能：管理員權限切換、強制關閉檔案總管、硬體功耗限制。
#>

# --- 1. 自動檢查並請求管理員權限 ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "正在請求管理員權限..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "      RB 專用極簡省電工具 (GitHub 版)" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "1. 徹底關閉檔案總管 (停用自動重啟)" -ForegroundColor Red
    Write-Host "2. 恢復檔案總管 (啟用自動重啟)" -ForegroundColor Green
    Write-Host "3. 終極優化 (CPU 50% + 省電模式)" -ForegroundColor Yellow
    Write-Host "4. 恢復平衡模式 (預設)" -ForegroundColor Blue
    Write-Host "5. 退出"
    Write-Host "==========================================="
}

while ($true) {
    Show-Menu
    $Selection = Read-Host "請輸入選項 (1-5)"

    switch ($Selection) {
        "1" {
            Write-Host "正在徹底關閉 Explorer..." -ForegroundColor Yellow
            # 修改登錄檔，防止 Explorer 自動重啟
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 0
            taskkill /f /im explorer.exe
            Write-Host "檔案總管已關閉，桌面已隱藏。" -ForegroundColor Green
            Pause
        }
        "2" {
            Write-Host "正在恢復 Explorer..." -ForegroundColor Yellow
            # 恢復自動重啟設定
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 1
            start-process explorer.exe
            Write-Host "檔案總管已恢復。" -ForegroundColor Green
            Pause
        }
        "3" {
            Write-Host "切換至極限省電模式..." -ForegroundColor Yellow
            # 設定為省電模式 GUID
            powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a
            # 限制 CPU 最高狀態為 50%
            powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 50
            powercfg /setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 50
            powercfg /setactive scheme_current
            Write-Host "CPU 已限制在 50% 功耗。" -ForegroundColor Green
            Pause
        }
        "4" {
            Write-Host "恢復平衡模式..." -ForegroundColor Cyan
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            Write-Host "系統已恢復正常。" -ForegroundColor Green
            Pause
        }
        "5" { 
            # 退出前確保自動重啟功能是開啟的，避免系統出錯
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 1
            exit 
        }
        default { Write-Host "無效選項，請重新輸入。" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
