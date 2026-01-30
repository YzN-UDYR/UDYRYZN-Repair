# 1. YÖNETİCİ KONTROLÜ
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER VE PROTOKOL SABİTLEME
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (Kritik: GitHub'daki version.txt ile birebir aynı olmalı!)
$CURRENT_VER = "11.0" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. DÖNGÜ KIRICI GÜNCELLEME SİSTEMİ
Write-Host "  $Y[*] Versiyon kontrolü yapılıyor...$W"
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENİ SÜRÜM TESPİT EDİLDİ: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik güncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $C[*] Kodlar yenileniyor ve dosya üzerine yazılıyor...$W"
            Invoke-WebRequest -Uri $URL_SCRIPT -OutFile $PSCommandPath -UserAgent $UA 
            Write-Host "  $G[+] Güncelleme BAŞARILI. Lütfen bu pencereyi kapatıp tekrar açın.$W"
            Pause; exit
        }
    } else {
        Write-Host "  $G[+] Sistem güncel (v$CURRENT_VER). Operasyon başlıyor...$W"
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "  $R[-] Bağlantı kurulamadı, çevrimdışı devam ediliyor...$W"
}

Clear-Host
# 5. ANA LOGO VE TANITIM (v8.3 Bat Mirası)
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
Write-Host ""

# --- OPERASYONLAR (v8.3 BAT TAM LİSTE) ---

# [01] NETWORK RESET
Write-Host "  $P$PAD_TXT[01]$W $C AĞ KATMANI DERİN SIFIRLAMA$W"
netsh winsock reset | Out-Null; netsh int ip reset | Out-Null
ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W Ağ yığını sıfırlandı."

# [02] SFC SCAN
Write-Host "  $P$PAD_TXT[02]$W $C SİSTEM DOSYASI ONARIMI (SFC)$W"
sfc /scannow

# [03] DISM (RESTOREHEALTH + RESETBASE)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERİN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W Windows bileşen deposu temizlendi."

# [04] EVENT LOG CLEANUP
Write-Host "  $P$PAD_TXT[04]$W $C SİSTEM LOGLARI TEMİZLİĞİ$W"
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ForEach-Object { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) }
Write-Host "  $G$PAD_TXT [DONE]$W Olay günlükleri sıfırlandı."

# [05] ICON CACHE REBUILD
Write-Host "  $P$PAD_TXT[05]$W $C İKON BELLEĞİ VE EXPLORER RESTORASYONU$W"
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Remove-Item "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer
Write-Host "  $G$PAD_TXT [DONE]$W Gezgin ve ikonlar yenilendi."

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTİVASYONU$W"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
Write-Host "  $G$PAD_TXT [DONE]$W USB otomatik açılış aktif edildi."

# KAPANIŞ
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Read-Host "Kapatmak için Enter'a basınız..."
