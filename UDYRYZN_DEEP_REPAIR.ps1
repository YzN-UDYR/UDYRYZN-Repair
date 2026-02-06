# 1. YONETICI KONTROLU
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (v12.6 - Mühürlü Sürüm)
$CURRENT_VER = "12.6" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "
$PAD_SUB  = "               " 

# Hizalama Yardimcisi (70 Karakter Siniri)
function Out-AlignedDone {
    param([string]$text)
    $cleanText = $text -replace '\e\[[0-9;]*m', '' # ANSI renk kodlarini temizle
    $dotCount = 65 - $cleanText.Length
    if ($dotCount -lt 1) { $dotCount = 1 }
    Write-Host -NoNewline ($text + ("." * $dotCount))
    Write-Host " $G[DONE]$W"
}

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. GUNCELLEME MOTORU (Otonom & Sabit Lojik)
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5 -UseBasicParsing
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 
    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM TESPIT EDILDI: v$ONLINE_VER$W"
        if ((Read-Host "  Guncellensin mi? (E/H)") -eq "E") {
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            exit
        }
    }
} catch { }

Clear-Host
# 5. ANA LOGO
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔═══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W $CURRENT_VER.NET  $B║$W"
Write-Host "  $B$PAD_BOX╚═══════════════════════════════════════════════════════════════════════════════════╝$W"

# --- OPERASYONLAR ---

# [01] AG SIFIRLAMA (Perfect Alignment)
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
$netOps = @(
    @{ cmd = "netsh winsock reset"; txt = "Winsock Protokolü Sifirlama" },
    @{ cmd = "netsh int ip reset";  txt = "IP Yapilandirmasi Sifirlama" },
    @{ cmd = "ipconfig /flushdns";  txt = "DNS Onbelleği Temizleniyor" }
)
foreach ($op in $netOps) {
    Invoke-Expression $op.cmd | Out-Null
    Out-AlignedDone "$PAD_SUB $($op.txt)"
}
Write-Host ""

# [02] SFC SCAN (Real-Time Telemetri & Aligned)
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
Write-Host "$PAD_SUB Sistem taraması aktif. Lütfen bekleyin..."
$sfcProc = Start-Process cmd -ArgumentList "/c sfc /scannow" -NoNewWindow -PassThru -RedirectStandardOutput "sfc_out.log"
while (!$sfcProc.HasExited) {
    if (Test-Path "sfc_out.log") {
        $content = Get-Content "sfc_out.log" -Tail 1 -ErrorAction SilentlyContinue
        if ($content -match "(\d+%)") { Write-Host -NoNewline "`r$PAD_SUB SFC Taraması İlerleme Durumu: $G$($matches[1])$W" }
    }
    Start-Sleep -Milliseconds 300
}
Out-AlignedDone "`r$PAD_SUB SFC Sistem Taraması Tamamlandı"
Remove-Item "sfc_out.log" -ErrorAction SilentlyContinue
Write-Host ""

# [03] DISM (Real-Time & Aligned)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth | ForEach-Object {
    if ($_ -match "(\d+\.\d+%)") { Write-Host -NoNewline "`r$PAD_SUB DISM Onarim Durumu: $G$($matches[1])$W" }
}
Write-Host "`n$PAD_SUB Bilesen deposu temizleniyor (ResetBase)..."
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Out-AlignedDone "$PAD_SUB DISM Görüntü Tamiri ve Temizliği"
Write-Host ""

# [04] LOG TEMIZLIGI
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
$Logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
$s = 0; foreach ($Log in $Logs) { try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($Log.LogName); $s++ } catch {} }
Out-AlignedDone "$PAD_SUB $s Adet Sistem Günlük Kaydı Temizlendi"
Write-Host ""

# [05] ICON CACHE
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Get-ChildItem "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -ErrorAction SilentlyContinue | Remove-Item -Force
    Start-Process explorer; Out-AlignedDone "$PAD_SUB Explorer ve Ikon Önbelleği Yenilendi"
} catch { Start-Process explorer }
Write-Host ""

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTIVASYONU$W"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
Out-AlignedDone "$PAD_SUB Otomatik Kullanma Ayarları Mühürlendi"
Write-Host ""

# [07] WINGET (Elite Aligned Telemetry)
Write-Host "  $P$PAD_TXT[07]$W $C SISTEM UYGULAMALARI GUNCELLEME (WINGET)$W"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "$PAD_SUB Guncellemeler denetleniyor..."
    $currentApp = "Sistem"
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements | ForEach-Object {
        $line = $_.Trim()
        if ($line -match "Found\s+(.+)\s+\[") { $currentApp = $matches[1] }
        if ($line -match "(\d+%)") {
            Write-Host -NoNewline "`r$PAD_SUB $C$currentApp$W guncelleniyor... $Y$($matches[1])$W"
        }
        elseif ($line -match "Successfully installed") {
            Write-Host -NoNewline "`r" # Mevcut yüzde satırını temizlemek için başa dön
            Out-AlignedDone "$PAD_SUB $C$currentApp$W guncellendi"
        }
    }
} else { Write-Host "$PAD_SUB $R[FAIL]$W Winget bulunamadı." }

# KAPANIS
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Pencereyi kapatmak için Enter'a basınız..."
