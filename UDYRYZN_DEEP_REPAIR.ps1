# 1. YÖNETİCİ KONTROLÜ
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER VE PROTOKOL SABİTLEME
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (v11.5 Precision)
$CURRENT_VER = "11.7" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "
$PAD_SUB  = "               " # 15 Karakter: 'S' harfinin tam altı.

# 4. HİZALAMA VE DİNAMİK SATIR MOTORU
function Invoke-Precision {
    param([string]$Cmd, [string]$Args)
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $Cmd
    $process.StartInfo.Arguments = $Args
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.CreateNoWindow = $true
    [void]$process.Start()
    
    while (!$process.StandardOutput.EndOfStream) {
        $line = $process.StandardOutput.ReadLine()
        if ($line -match "\d+[%]") {
            # Yüzde içeren satırları aynı noktada günceller (Vertical Spam Önleyici)
            Write-Host -NoNewline "`r$PAD_SUB$($line.Trim())"
        } elseif ($line.Trim()) {
            Write-Host "$PAD_SUB$($line.Trim())"
        }
    }
    $process.WaitForExit()
    Write-Host "" 
}

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 5. AKILLI GÜNCELLEME KONTROLÜ (2 Saniye Deneme)
Write-Host "  $Y[*] Güncelleme sunucusuna bağlanılıyor (2sn)...$W"
$updateTask = Start-Job -ScriptBlock {
    param($u, $v, $ua)
    try { 
        $data = Invoke-RestMethod -Uri $u -UserAgent $ua -TimeoutSec 2 -UseBasicParsing
        return $data.Trim()
    } catch { return $null }
} -ArgumentList $URL_VERSION, $CURRENT_VER, $UA

if (Wait-Job $updateTask -Timeout 2) {
    $ONLINE_VER = Receive-Job $updateTask
    if ($ONLINE_VER -and [decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENİ SÜRÜM TESPİT EDİLDİ: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik güncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Write-Host "  $G[+] Güncellendi. Lütfen tekrar açın.$W"; Pause; exit
        }
    }
}
Remove-Job $updateTask -Force

Clear-Host
# 6. ANA LOGO (v8.3 Mirası)
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W $CURRENT_VER.NET  $B║$W"
Write-Host "  $B$PAD_BOX╚══════════════════════════════════════════════════════════════════════════════════╝$W"

# --- OPERASYONLAR (v8.3 BAT EKSİKSİZ TAM LİSTE) ---

# [01] NETWORK RESET
Write-Host "  $P$PAD_TXT[01]$W $C AG SIFIRLAMA...$W"
try {
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns | Out-Null
    Write-Host "$PAD_SUB $G[DONE]$W Ag yapilandirmasi sifirlandi."
} catch { Write-Host "$PAD_SUB $Y[PARTIAL]$W" }
Write-Host ""

# [02] SFC SCAN (Precision Motor)
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM ONARIMI (SFC)$W"
Invoke-Precision "sfc" "/scannow"
Write-Host "$PAD_SUB $G[DONE]$W Tarama bitti."
Write-Host ""

# [03] DISM (Precision Motor)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
Invoke-Precision "dism" "/online /cleanup-image /restorehealth"
Write-Host "$PAD_SUB Bilesen deposu temizleniyor (ResetBase)..."
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "$PAD_SUB $G[DONE]$W"
Write-Host ""

# [04] EVENT LOGS
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
$Logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
$s = 0; $k = 0
foreach ($Log in $Logs) {
    try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($Log.LogName); $s++ }
    catch { $k++ }
}
Write-Host "$PAD_SUB $Y[STATUS]$W ($s basarili, $k kilitli gunluk atlandi)"
Write-Host ""

# [05] ICON CACHE
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    $f = Get-ChildItem "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -ErrorAction SilentlyContinue
    $f | Remove-Item -Force -ErrorAction SilentlyContinue
    Start-Process explorer
    Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Start-Process explorer }
Write-Host ""

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTIVASYONU$W"
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
    Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Write-Host "$PAD_SUB $Y[PARTIAL]$W" }

# KAPANIŞ
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Read-Host "Kapatmak için Enter'a basınız..."
