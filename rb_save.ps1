# RB 極致省電優化工具 (PowerShell 版)
$Action = Read-Host "
===========================================
        RB 專用極簡省電工具 (一鍵版)
===========================================
1. 關閉檔案總管 (隱藏桌面)
2. 恢復檔案總管 (顯示桌面)
3. 終極優化 (CPU 鎖定 50% + 省電模式)
4. 恢復正常模式
5. 退出
請輸入選項 (1-5)"

switch ($Action) {
    "1" { stop-process -name explorer -force }
    "2" { start-process explorer }
    "3" { 
        powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a
        powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 50
        powercfg /setactive scheme_current
        Write-Host "已進入極限省電模式" -ForegroundColor Green
    }
    "4" { 
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        Write-Host "已恢復平衡模式" -ForegroundColor Cyan
    }
    "5" { exit }
}
