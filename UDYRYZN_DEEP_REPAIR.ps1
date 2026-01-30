# 1. YONETICI KONTROLU
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL SABITLEME (Gorsel Bozulma Cozumu)
# Bu satir, ekrandaki 'â' gibi garip karakterleri engeller.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA
$CURRENT_VER = "10.0" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. GELISTIRILMIS GUNCELLEME VE RE-BOOT MANTIGI
Write-Host "  $Y[*] Guncelleme ajani sorgulaniyor...$W"
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] Yeni versiyon (v$ONLINE_VER) mevcut.$W"
        $choice = Read-Host "  Guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $C[*] Kodlar yenileniyor...$W"
            # Yeni kodu indir
            Invoke-WebRequest -Uri $URL_SCRIPT -OutFile $PSCommandPath -UserAgent $UA 
            
            Write-Host "  $G[+] Guncelleme basarili. Sistem yeni motoru atesliyor...$W"
            # Eski restart yontemi yerine daha temiz bir gecis:
            Start-Sleep -Seconds 1
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"
            exit
        }
    }
} catch { Write-Host "  $R[-] Baglanti Kurulamadi.$W" }

Clear-Host
# 5. RESTORE EDILMIS LOGO VE TANITIM KUTUSU 
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

# --- OPERASYONLAR ---
# [01] AG SIFIRLAMA
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
netsh winsock reset | Out-Null; netsh int ip reset | Out-Null
ipconfig /flushdns | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W"

# [02] SISTEM ONARIMLARI (SFC & DISM)
Write-Host "  $P$PAD_TXT[02]$W $C SFC VE DISM ONARIMLARI...$W"
sfc /scannow
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W"

# [03] TEMIZLIK
Write-Host "  $P$PAD_TXT[03]$W $C LOGLAR VE IKON BELLEGI TEMIZLENIYOR...$W"
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ForEach-Object { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) }
Write-Host "  $G$PAD_TXT [DONE]$W"

Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Read-Host "Kapatmak icin Enter'a basiniz..."
