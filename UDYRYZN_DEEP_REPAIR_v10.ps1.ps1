if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Yapilandirma
$CURRENT_VER = "10.0"
$URL_VERSION = "https://raw.githubusercontent.com/kullanici/repo/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/kullanici/repo/main/UDYRYZN_DEEP_REPAIR_v11.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v10"
Clear-Host

# 1. Guncelleme Denetimi (Pre-Boot)
Write-Host "  $Y[*] Sistem kontrol ediliyor...$W"
try {
    $ONLINE_VER = (Invoke-RestMethod -Uri $URL_VERSION -TimeoutSec 3).Trim()
    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM MEVCUT: v$ONLINE_VER$W"
        $choice = Read-Host "  Guncellemek istiyor musunuz? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Invoke-WebRequest -Uri $URL_SCRIPT -OutFile "$env:USERPROFILE\Desktop\UDYRYZN_DEEP_REPAIR_v$ONLINE_VER.ps1"
            Write-Host "  $G[+] Guncel dosya masaustune indirildi.$W"
            Pause; exit
        }
    }
} catch { }

Clear-Host
# 2. Ana Logo ve Arayuz
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W 10.0.NET $B║$W"
Write-Host "  $B$PAD_BOX╚══════════════════════════════════════════════════════════════════════════════════╝$W"
Write-Host ""

# --- OPERASYONLAR ---
# [01] Network
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
ipconfig /flushdns | Out-Null
Write-Host "  $G$PAD_TXT [$W DONE $G]$W Ag yapilandirmasi sifirlandi."
Write-Host ""

# [02] SFC
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
sfc /scannow
Write-Host ""

# [03] DISM
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM$W"
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [$W DONE $G]$W Bilesen deposu temizlendi."
Write-Host ""

# [04] Event Logs
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ForEach-Object { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) }
Write-Host "  $G$PAD_TXT [$W DONE $G]$W Olay gunlukleri sifirlandi."
Write-Host ""

# Kapanis
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Kapatmak icin Enter'a basiniz..."