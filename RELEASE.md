# Release Süreci

Yeni bir sürüm yayınlamak için şu adımları takip edin:

## Adım 1: Version'u Güncelle
```bash
# pubspec.yaml dosyasında version satırını güncelleyin
# Örneğin: version: 1.0.3+3
```

## Adım 2: Commit Et
```bash
git add pubspec.yaml
git commit -m "Version: Bump to X.Y.Z"
git push origin main
```

## Adım 3: Tag Oluştur ve Push Et
```bash
git tag -a vX.Y.Z -m "Feature/Fix: Description here"
git push origin vX.Y.Z
```

**Not:** GitHub Actions otomatik olarak:
1. APK'yı build eder
2. GitHub Release'te yayınlar
3. APK dosyasını ekler
4. Türkçe açıklamasını ekler

## Sürüm Numaralandırması

- **Major.Minor.Patch+BuildNumber**
- Örnek: `1.0.3+3`
- Build number her sürümde artırılır

## Örnek Tam İşlem

```bash
# 1. pubspec.yaml'ı düzenle: 1.0.3+3
git add pubspec.yaml
git commit -m "Version: Bump to 1.0.3"
git push origin main

# 2. Tag oluştur
git tag -a v1.0.3 -m "Feature: Add refresh button to reload paired devices"
git push origin v1.0.3

# 3. GitHub Actions çalışacak (4-5 dakika)
# 4. Release sayfasında otomatik yayınlanacak
```
