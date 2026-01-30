# 1. Yönetici İzni Kontrolü
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Bağlantı Protokolü (GitHub TLS 1.2 Zorunluluğu)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3. Güncelleme Yapılandırması (Kritik: Sabit Raw Linkler)
$CURRENT_VER = "11.0" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

# 4. Tasarım Değişkenleri
$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "        "
$PAD_BOX  = "  "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"

# 5. Akıllı Güncelleme Denetimi (Overwriting Logic)
Clear-Host
Write-Host " `n  $Y[*] Sunucuya baglaniliyor...$W"
try {
    # GitHub'ın reddetmemesi için User-Agent (Mozilla) kimliğiyle bağlanıyoruz
    $response = Invoke-WebRequest -Uri $URL_VERSION -UseBasicParsing -TimeoutSec 5 -Headers @{"User-Agent"="Mozilla/5.0"}
    $ONLINE_VER = $response.Content.Trim()

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM MEVCUT: v$ONLINE_VER$W"
        $choice = Read-Host "  Yazilimi simdi guncellemek istiyor musunuz? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $Y[*] Guncelleme indiriliyor ve dosya yenileniyor...$W"
            $NewCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UseBasicParsing -Headers @{"User-Agent"="Mozilla/5.0"}).Content
            
            # Scriptin kendi dosyasının içeriğini değiştiriyoruz
            Set-Content -Path $PSCommandPath -Value $NewCode -Force
            
            Write-Host "  $G[+] Basarili! Yeni surum baslatiliyor...$W"
            Start-Sleep -Seconds 1
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            exit
        }
    } else {
        Write-Host "  $G[+] Yazilim guncel (v$CURRENT_VER).$W"
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "  $R[-] Sunucuya baglanilamadi. Cevrimdisi mod aktif.$W"
    Start-Sleep -Seconds 2
}

# 6. Ana Arayüz (Düzeltilmiş ve Hizalanmış Logo)
Clear-Host
Write-Host "$C"
Write-Host "$PAD_LOGO  ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$PAD_LOGO  ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$PAD_LOGO  ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$PAD_LOGO  ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$PAD_LOGO  ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$PAD_LOGO   ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝"
Write-Host "$W"
Write-Host "  $B$PAD_BOX╔════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W $R[MODE]$W: Deep Repair Engine $B║$W $Y[USER]$W: $env:USERNAME $B║$W $Y[VER]$W: $CURRENT_VER $B║$W"
Write-Host "  $B$PAD_BOX╚════════════════════════════════════════════════════════════════════╝$W"
Write-Host ""

# 7. Operasyonlar
Write-Host "  $P[01]$W $C AG SIFIRLAMA (Winsock/IP/DNS)$W"
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
ipconfig /flushdns | Out-Null
Write-Host "  $G >> DURUM: TAMAMLANDI$W"
Write-Host ""

Write-Host "  $P[02]$W $C SISTEM ONARIMI (SFC)$W"
sfc /scannow
Write-Host ""

Write-Host "  $B" + ("═" * 60) + "$W"
Write-Host "  $G                     ISLEM TAMAMLANDI.$W"
Write-Host "  $B" + ("═" * 60) + "$W"
Write-Host ""
Read-Host " Kapatmak icin Enter'a basiniz..."
