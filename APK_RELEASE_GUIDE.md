# 🚀 Koza RC Car - APK Release Oluşturma Rehberi

## 📱 Release APK Oluşturma Adımları

### Adım 1: Uygulamayı Hazırla

Uygulamanın Release'e hazır olduğundan emin ol:

```bash
cd /workspaces/benim_flutter_projem

# Bağımlılıkları kontrol et
flutter pub get

# Lint kontrol
flutter analyze
```

### Adım 2: İçeriği Sıkıştır (Shrinking)

Release APK'nın optimize edilmiş olması için:

```bash
# Projenin kökünde build.gradle.kts dosyasını aç
android/app/build.gradle.kts

# Aşağıdaki konfigürasyonu kontrol et:
```

**build.gradle.kts kontrolü** (android/app/build.gradle.kts):

```kotlin
buildTypes {
    release {
        signingConfig signingConfigs.release
        shrinkResources true
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### Adım 3: Anahtar Deposu (Keystore) Oluştur

İlk defa APK oluşturursan anahtar deposu oluşturmak gerekir:

```bash
# Keystore oluştur (Linux/Mac)
keytool -genkey -v -keystore ~/koza_rc_car.jks -keyalg RSA -keysize 2048 -validity 10000 -alias koza_rc_car

# Sorular şu şekilde cevaplayacaksın:
# Anahtar deposunun parolası: (güçlü bir parola belirle)
# Anahtar parolası: (aynı veya farklı parola)
# Ad ve Soyadı: Adını Gir
# Organizasyon Birimi: Geliştirici
# Organizasyon: Koza Robotics
# Şehir: Istanbul
# Eyalet/Bölge: Türkiye
# Ülke Kodu: TR
# Doğru mu? (Y/N): y
```

### Adım 4: Android Yapılandırmasını Güncelle

Keystore bilgilerini Flutter'a bildir:

**1. android/local.properties dosyasını düzenle:**

```properties
sdk.dir=/usr/lib/android-sdk
flutter.sdk=/root/.flutter
flutter.buildMode=release

# Keystore bilgileri (eğer varsa)
storeFile=/root/koza_rc_car.jks
storePassword=your_store_password
keyAlias=koza_rc_car
keyPassword=your_key_password
```

**2. android/app/build.gradle.kts dosyasını düzenle:**

```kotlin
signingConfigs {
    release {
        keyAlias System.getenv("KEY_ALIAS") ?: "koza_rc_car"
        keyPassword System.getenv("KEY_PASSWORD") ?: "your_key_password"
        storeFile System.getenv("STORE_FILE") ? file(System.getenv("STORE_FILE")) : file("/root/koza_rc_car.jks")
        storePassword System.getenv("STORE_PASSWORD") ?: "your_store_password"
    }
}
```

### Adım 5: Release APK Oluştur

Terminal'de şu komutu çalıştır:

```bash
cd /workspaces/benim_flutter_projem

# Release APK oluştur
flutter build apk --release
```

**Beklenen Çıktı:**

```
✓ Built /workspaces/benim_flutter_projem/build/app/outputs/apk/release/app-release.apk
```

### Adım 6: APK'nı Kontrol Et

```bash
# APK'nın konumunu kontrol et
ls -lh /workspaces/benim_flutter_projem/build/app/outputs/apk/release/

# Dosya boyutunu görmeli:
# -rw-r--r-- 1 root root 50M ... app-release.apk
```

### Adım 7: Cihaza Yükle

Oluşturulan APK'yı Android cihazına yükle:

```bash
# USB ile bağlı cihaza yükle
flutter install --release

# Veya doğrudan APK dosyasını yükle
adb install -r build/app/outputs/apk/release/app-release.apk
```

---

## 🔧 OPSIYONEL: Daha Küçük APK Oluştur

### Split APK Kullanarak (Architecture bazında)

```bash
# Mimari bazında split APK'lar oluştur
flutter build apk --release --split-per-abi
```

**Sonuç:**
```
✓ app-arm64-v8a-release.apk (~30MB)
✓ app-armeabi-v7a-release.apk (~25MB)
✓ app-x86_64-release.apk (~35MB)
```

Kullanıcıya kendi cihazına uygun mimari olanı ver.

### App Bundle Oluştur (Google Play için)

```bash
# AAB dosyası oluştur (Google Play Store'da dinamik boyut kontrolü)
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

---

## 📊 Dosya Boyutları

| Dosya Türü | Boyut | Avantaj |
|-----------|-------|---------|
| app-release.apk | ~50MB | Tüm mimarileri içerir |
| app-arm64-v8a-release.apk | ~30MB | Sadece 64-bit ARM |
| app-armeabi-v7a-release.apk | ~25MB | Sadece 32-bit ARM |
| app-release.aab | ~35MB | Google Play için optimize |

---

## ✅ Kontrol Listesi

Oluşturulmadan Önce:

- [ ] Code analyze'ı geçti (`flutter analyze`)
- [ ] Tüm testler çalışırsa (`flutter test`)
- [ ] Uygulamayı manuel test ettim
- [ ] Version number güncellendi
- [ ] Keystore parolasını not ettim
- [ ] Android SDK güncel
- [ ] Yeterli disk alanı var (~3GB)

---

## 🔐 Keystore Yönetimi

### Keystore'u Güvenle Sakla

```bash
# Keystore dosyasını yedekle
cp ~/koza_rc_car.jks ~/koza_rc_car.backup.jks

# Parolaları not et (güvenli yerde)
echo "Store Password: ..." > ~/keystore_passwords.txt
echo "Key Alias: koza_rc_car" >> ~/keystore_passwords.txt
echo "Key Password: ..." >> ~/keystore_passwords.txt
```

### Keystore Bilgilerini Kontrol Et

```bash
# Keystore'daki bilgileri göster
keytool -list -v -keystore ~/koza_rc_car.jks

# Parol sor ve detayları göster
keytool -list -v -keystore ~/koza_rc_car.jks -alias koza_rc_car
```

---

## 🐛 Sık Sorunlar ve Çözümleri

### Sorun 1: "Keystore dosyası bulunamadı"

```bash
# Keystore dosyasının tam yolunu kontrol et
keytool -list -keystore /root/koza_rc_car.jks

# Eğer yoksa yenisini oluştur
keytool -genkey -v -keystore ~/koza_rc_car.jks -keyalg RSA -keysize 2048 -validity 10000
```

### Sorun 2: "Yanlış parola"

```bash
# Keystore'daki şifreyi değiştir
keytool -storepasswd -keystore ~/koza_rc_car.jks

# Alias şifreyi değiştir
keytool -keypasswd -keystore ~/koza_rc_car.jks -alias koza_rc_car
```

### Sorun 3: "APK çok büyük"

```bash
# Split APK kullan
flutter build apk --release --split-per-abi

# veya App Bundle kullan
flutter build appbundle --release
```

### Sorun 4: "Yüklemede hata"

```bash
# Önceki APK'yı kaldır
adb uninstall com.example.koza_rc_car

# Yenisini yükle
adb install -r build/app/outputs/apk/release/app-release.apk

# Veya Android Studio üzerinden yükle
flutter install --release
```

---

## 📲 APK'yı Dağıt

### Seçenek 1: Direct Download (Web)

1. Web sunucunuza APK dosyasını yükle
2. QR kod oluştur
3. Kullanıcılarla paylaş

### Seçenek 2: Google Play Store

1. Google Play Developer Hesabı oluştur
2. APK veya AAB'yi yükle
3. Store listing'i doldu
4. Yayınla

### Seçenek 3: GitHub Releases

```bash
# GitHub'a APK dosyasını yükle
# Repository → Releases → New Release
# APK dosyasını attach et
# Publish
```

### Seçenek 4: Email/Direct Sharing

```bash
# APK dosyasını doğrudan paylaş
ls -lh build/app/outputs/apk/release/app-release.apk

# E-posta, Dropbox, Google Drive, vb. kullanarak gönder
```

---

## 🔍 APK'nı Analiz Et

### APK Boyutunu Analiz Et

```bash
# APK'nın içeriğini göster
unzip -l build/app/outputs/apk/release/app-release.apk | head -20

# Dosya boyutlarını kontrol et
du -h build/app/outputs/apk/release/app-release.apk
```

### APK'yı İndir ve Kapat

```bash
# APK bilgilerini göster
aapt dump badging build/app/outputs/apk/release/app-release.apk

# Minimum Android sürümü, paket adı, vb. göre
```

---

## 📝 Sürüm Numarasını Güncelle

pubspec.yaml dosyasını düzenle:

```yaml
# Eski
version: 1.0.0+1

# Yeni
version: 1.0.1+2
```

**Anlamı:**
- 1.0.1 = Görünür sürüm
- 2 = Build numarası

---

## 🎯 Son Kontroller

Yayınlamadan Önce:

```bash
# 1. Lint kontrol
flutter analyze

# 2. Format kontrol
dart format lib/

# 3. Uygulamayı test et
flutter test

# 4. Release build test et
flutter build apk --release --debug

# 5. Cihazda test et
flutter install --release
```

---

## 📋 Hızlı Komut Özeti

```bash
# Keystore oluştur
keytool -genkey -v -keystore ~/koza_rc_car.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias koza_rc_car

# Release APK oluştur
flutter build apk --release

# Split APK oluştur
flutter build apk --release --split-per-abi

# App Bundle oluştur
flutter build appbundle --release

# Cihaza yükle
flutter install --release

# Doğrudan APK'nı yükle
adb install -r build/app/outputs/apk/release/app-release.apk

# APK bilgilerini göster
aapt dump badging build/app/outputs/apk/release/app-release.apk
```

---

## ✨ Başarıyla Yayınlandıktan Sonra

1. Sürüm numarasını güncelle
2. Changelog dosyası oluştur
3. Release notes yaz
4. Kullanıcılara duyur
5. Geri bildirimleri topla

---

**Tebrikler!** Koza RC Car uygulaması yayında! 🎉

*Herhangi bir sorun varsa, APK oluşturma sırasında hata mesajlarını dikkatli oku.*

---

**Ek Kaynaklar:**
- [Flutter Build APK Docs](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Keytool Documentation](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)
