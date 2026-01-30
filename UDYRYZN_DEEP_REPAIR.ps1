# 1. YONETICI KONTROLU
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL (â Karakteri Cozumu)
# Konsolu ve dosya okumayı UTF-8'e zorluyoruz.
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (Sabit 10.0)
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

# 4. GELISTIRILMIS GUNCELLEME (Encoding Koruma Ile)
Write-Host "  $Y[*] Guncelleme ajanı baglantısı kuruluyor...$W"
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM MEVCUT: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $C[*] Yeni kodlar indiriliyor ve UTF-8 formatında kaydediliyor...$W"
            # Sadece indirmek yetmez, UTF-8 olarak kaydetmeyi zorluyoruz.
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            
            Write-Host "  $G[+] Guncelleme tamamlandı. Lutfen pencereyi kapatıp tekrar acın.$W"
            Pause; exit
        }
    } else {
        Write-Host "  $G[+] Sistem guncel (v$CURRENT_VER).$W"
        Start-Sleep -Seconds 1
    }
} catch { Write-Host "  $R[-] Baglantı kurulamadı, cevrimdısı mod aktif.$W" }

Clear-Host
# 5. ANA LOGO VE TANITIM KUTUSU (Geri Getirilen Tasarım)
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
Write-Host "  $R$PAD_TXT  [!] DIKKAT: BU ISLEM DERIN ONARIM ICERDIGI ICIN UZUN SUREBILIR.$W"
Write-Host "  $R$PAD_TXT  [!] LUTFEN PENCEREYI KAPATMAYIN VE ISLEMIN BITMESINI BEKLEYIN.$W"
Write-Host ""

# --- OPERASYONLAR (v8.3 Bat Eksiksiz Aktarıldı) ---
# [01] AG SIFIRLAMA
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
netsh winsock reset | Out-Null; netsh int ip reset | Out-Null
ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W"

# [02] SFC ONARIMI
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
sfc /scannow

# [03] DISM (RESTORE + RESETBASE)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W"

# [04] EVENT LOGS
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ForEach-Object { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) }
Write-Host "  $G$PAD_TXT [DONE]$W"

# [05] ICON CACHE REBUILD
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Remove-Item "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer
Write-Host "  $G$PAD_TXT [DONE]$W"

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB VE MEDYA AUTOPLAY AKTIVASYONU$W"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
Write-Host "  $G$PAD_TXT [DONE]$W"

# KAPANIS
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Kapatmak icin Enter'a basınız..."
