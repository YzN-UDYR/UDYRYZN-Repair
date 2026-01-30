**UDYRYZN DEEP REPAIR ENGINE v11.0 🚀**
Windows sistem hatalarını onarmak, ağ katmanlarını sıfırlamak ve gereksiz sistem yüklerini temizlemek için tasarlanmış, PowerShell tabanlı profesyonel bir bakım otomasyonudur.

**🛠 Temel Özellikler**
[01] Ağ Katmanı Sıfırlama: Winsock, IP yığını sıfırlama ve DNS temizliği (FlushDNS).

[02] SFC Onarımı: Windows sistem çekirdeği bütünlük taraması.

[03] DISM Derin Onarım: RestoreHealth ve ResetBase ile bileşen deposu restorasyonu.

[04] Event Log Temizliği: Şişmiş sistem ve uygulama günlüklerinin milisaniyeler içinde silinmesi.

[05] Icon Cache Restorasyonu: Bozulmuş ikon veritabanlarının Explorer resetlenerek yenilenmesi.

[06] USB Autoplay Aktivasyonu: Kayıt defteri üzerinden USB otomatik kullan kilidinin kaldırılması.


**🚀 Kurulum ve Çalıştırma**
1. Dosyayı İndirin
**UDYRYZN_DEEP_REPAIR.ps1** dosyasını bilgisayarınıza indirin.

2. Yönetici Olarak Çalıştırın
Dosyaya Sağ Tıklayın ve "PowerShell ile Çalıştır" (Run with PowerShell) seçeneğini seçin. Yazılım, yönetici izni yoksa otomatik olarak izin isteyecektir.



**🆘 Sorun Giderme (Sıkça Sorulan Sorular)**
_🔴 "Script Çalıştırma Yasak" Hatası Alıyorum?_
Windows, varsayılan olarak dışarıdan indirilen PowerShell scriptlerinin çalışmasını engeller. Bu engeli aşmak için şu adımları izleyin:

Başlat menüsüne PowerShell yazın.

Sağ tıklayıp "Yönetici Olarak Çalıştır" deyin.

Açılan ekrana şu komutu yapıştırın ve Enter'a basın: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Artık yazılımı sorunsuz çalıştırabilirsiniz.


_🟠 Ekranda "â" Gibi Garip Karakterler Var?_
Bu bir karakter kodlama (encoding) hatasıdır. Yazılım v11.0 ile bu sorunu otomatik çözmeye çalışır. Yine de sorun yaşarsanız:

Dosyayı Visual Studio Code ile açın.

Sağ alttaki kodlama kısmından "Save with Encoding" seçeneğini seçip "UTF-8 with BOM" olarak kaydedin.


_🟡 Güncelleme Döngüsünde Kalıyor?_
Yazılım her açılışta GitHub üzerinden versiyon kontrolü yapar. Eğer sürekli "Güncellensin mi?" diye soruyorsa, indirdiğiniz dosyanın içindeki sürüm numarası ile GitHub'daki version.txt dosyasındaki rakam uyuşmuyor demektir. Lütfen GitHub'daki en güncel .ps1 dosyasını manuel olarak indirin.


**📡 Akıllı Güncelleme Sistemi**
Yazılım, her açılışta güvenli TLS 1.2 protokolü ve Mozilla User-Agent kimliği ile GitHub'a bağlanır. Yeni bir sürüm tespit edildiğinde sizi uyarır ve tek bir tuşla kendi kodunu otomatik olarak günceller.

**NOT: Bu araç sistem üzerinde derin onarımlar yaptığı için işlem sırasında internet kesilebilir veya Windows Gezgini (Explorer) kapanıp açılabilir. Lütfen operasyon bitene kadar pencereyi kapatmayın.**
