# 1. YONETICI KONTROLU (Admin Privileges)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL (â Karakteri ve Baglanti Cozumu)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (Kritik: version.txt ile birebir ayni olmali!)
$CURRENT_VER = "11.2" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. AKILLI GUNCELLEME VE KENDI UZERINE YAZMA (Self-Overwriting)
Write-Host "  $Y[*] Guncelleme ajani ve TLS 1.2 hatti denetleniyor...$W"
try {
    # Decimal/Trim hatasini onlemek icin [string] zorlamasi yapildi
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5 -UseBasicParsing
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM TESPIT EDILDI: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $C[*] Yeni kodlar indiriliyor ve UTF-8 (BOM'lu) mühürleniyor...$W"
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Write-Host "  $G[+] Guncelleme tamamlandi. Lutfen scripti tekrar baslatin.$W"
            Pause; exit
        }
    } else {
        Write-Host "  $G[+] Sistem guncel (v$CURRENT_VER). Operasyon baslatiliyor...$W"
        Start-Sleep -Seconds 1
    }
} catch { Write-Host "  $R[-] Sunucuya ulasilamadi. Cevrimdisi modda devam ediliyor...$W" }

Clear-Host
# 5. ANA LOGO VE TANITIM KUTUSU (Full Restoration)
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

# [01] NETWORK RESET
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
try {
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null
    Write-Host "  $G$PAD_TXT [DONE]$W"
} catch { Write-Host "  $Y$PAD_TXT [PARTIAL] (Bazi ag ayarlari su an mesgul atlandi)$W" }

# [02] SFC SCAN
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
sfc /scannow

# [03] DISM
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W"

# [04] EVENT LOGS (Smart Feedback)
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
$Logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
$total = $Logs.Count; $success = 0; $skipped = 0
foreach ($Log in $Logs) {
    try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($Log.LogName); $success++ }
    catch { $skipped++ }
}
if ($skipped -gt 0) { Write-Host "  $Y$PAD_TXT [PARTIAL] ($success basarili, $skipped kilitli gunluk atlandi)$W" }
else { Write-Host "  $G$PAD_TXT [DONE]$W" }

# [05] ICON CACHE (Smart Feedback)
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    $cacheFiles = Get-ChildItem "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -ErrorAction SilentlyContinue
    $cSuccess = 0; $cFail = 0
    foreach ($file in $cacheFiles) {
        try { Remove-Item $file.FullName -Force -ErrorAction Stop; $cSuccess++ }
        catch { $cFail++ }
    }
    Start-Process explorer
    if ($cFail -gt 0) { Write-Host "  $Y$PAD_TXT [PARTIAL] (Bazi cache dosyalari kullanimda oldugu icin silinemedi)$W" }
    else { Write-Host "  $G$PAD_TXT [DONE]$W" }
} catch { Write-Host "  $R$PAD_TXT [FAIL] (Gezgin yeniden baslatilamadi)$W"; Start-Process explorer }

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTIVASYONU$W"
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
    Write-Host "  $G$PAD_TXT [DONE]$W"
} catch { Write-Host "  $Y$PAD_TXT [PARTIAL] (Kayit defteri kisitlamasi nedeniyle atlandi)$W" }

# KAPANIS
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Read-Host "Kapatmak için Enter'a basınız..."
