# 1. Yönetici İzni Kontrolü
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Güvenlik Protokolü ve Güncelleme Yapılandırması
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$CURRENT_VER = "11.0"
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

# 3. Görsel Değişkenler
$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. Güncelleme Denetimi
Write-Host "  $Y[*] Sunucuya baglaniliyor...$W"
try {
    $ONLINE_VER = (Invoke-RestMethod -Uri $URL_VERSION -TimeoutSec 5).Trim()
    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM MEVCUT: v$ONLINE_VER$W"
        $choice = Read-Host "  Guncel surumu masaustune indirmek istiyor musunuz? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Invoke-WebRequest -Uri $URL_SCRIPT -OutFile "$env:USERPROFILE\Desktop\UDYRYZN_DEEP_REPAIR_v$ONLINE_VER.ps1"
            Write-Host "  $G[+] Guncel dosya masaustune indirildi. Eski dosyayi silebilirsiniz.$W"
            Pause; exit
        }
    } else {
        Write-Host "  $G[+] Yazilim guncel (v$CURRENT_VER).$W"
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "  $R[-] Sunucuya baglanilamadi. Cevrimdisi mod aktif.$W"
    Start-Sleep -Seconds 1
}

Clear-Host
# 5. Ana Arayüz (ASCII Art)
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W $CURRENT_VER.NET $B║$W"
Write-Host "  $B$PAD_BOX╚══════════════════════════════════════════════════════════════════════════════════╝$W"
Write-Host ""

# 6. Operasyonlar
Write-Host "  $P$PAD_TXT[01]$W $C AG SIFIRLAMA$W"
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
ipconfig /flushdns | Out-Null
Write-Host "  $G >> STATUS: OK$W"
Write-Host ""

Write-Host "  $P$PAD_TXT[02]$W $C SISTEM ONARIMI (SFC)$W"
sfc /scannow
Write-Host ""

Write-Host "  $P$PAD_TXT[03]$W $C DISM ONARIMI$W"
dism /online /cleanup-image /restorehealth
Write-Host ""

Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Kapatmak icin Enter'a basiniz..."
