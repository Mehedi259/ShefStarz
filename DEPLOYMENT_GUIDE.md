# 🚀 Chef Starz - Deployment Guide

## ✅ সম্পন্ন হয়েছে

### 1. Bundle Identifier আপডেট
- **iOS**: `com.chefstarz.app`
- **Android**: `com.chefstarz.app`

### 2. iOS Permissions যোগ করা হয়েছে
- ✅ Camera Permission
- ✅ Photo Library Permission
- ✅ Photo Library Add Permission
- ✅ Microphone Permission

### 3. Android Permissions যোগ করা হয়েছে
- ✅ Internet
- ✅ Network State
- ✅ Camera
- ✅ Storage (Read/Write)
- ✅ Media Images & Video (Android 13+)

### 4. Android Release Signing Setup
- ✅ Signing configuration যোগ করা হয়েছে
- ✅ Keystore support যোগ করা হয়েছে

---

## 📱 iOS App Store Deployment

### Step 1: Xcode এ প্রজেক্ট খুলুন
```bash
open ios/Runner.xcworkspace
```

### Step 2: Signing & Capabilities
1. Xcode এ **Runner** target সিলেক্ট করুন
2. **Signing & Capabilities** ট্যাবে যান
3. **Team** সিলেক্ট করুন (93T4K6Y72D already set)
4. **Automatically manage signing** চেক করুন

### Step 3: Archive তৈরি করুন
1. Xcode এ **Product > Archive** সিলেক্ট করুন
2. অথবা command line থেকে:
```bash
flutter build ipa
```

### Step 4: TestFlight এ আপলোড
1. Archive সফল হলে **Organizer** window খুলবে
2. **Distribute App** বাটনে ক্লিক করুন
3. **App Store Connect** সিলেক্ট করুন
4. **Upload** সিলেক্ট করুন
5. সব default options রেখে **Upload** করুন

### Step 5: TestFlight এ Tester যোগ করুন
1. [App Store Connect](https://appstoreconnect.apple.com) এ যান
2. আপনার app সিলেক্ট করুন
3. **TestFlight** ট্যাবে যান
4. **Internal Testing** বা **External Testing** এ tester যোগ করুন
5. Build সিলেক্ট করুন এবং submit করুন

---

## 🤖 Android Play Store Deployment

### Step 1: Release Keystore তৈরি করুন (যদি না থাকে)

আপনার কাছে ইতিমধ্যে keystore আছে: `Chef Starz-upload-keystore.jks`

যদি নতুন তৈরি করতে হয়:
```bash
keytool -genkey -v -keystore ~/Chef\ Starz-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**গুরুত্বপূর্ণ**: Password এবং keystore file নিরাপদে রাখুন!

### Step 2: key.properties ফাইল তৈরি করুন

`android/key.properties` ফাইল তৈরি করুন:
```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=../Chef Starz-upload-keystore.jks
```

**নোট**: এই ফাইলটি `.gitignore` এ আছে, তাই git এ commit হবে না।

### Step 3: Release APK/AAB তৈরি করুন

**AAB (Play Store এর জন্য - recommended):**
```bash
flutter build appbundle --release
```

**APK (Direct install এর জন্য):**
```bash
flutter build apk --release
```

Build files পাবেন:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### Step 4: Play Console এ আপলোড

1. [Google Play Console](https://play.google.com/console) এ যান
2. আপনার app সিলেক্ট করুন
3. **Production** বা **Internal testing** track সিলেক্ট করুন
4. **Create new release** ক্লিক করুন
5. AAB file আপলোড করুন
6. Release notes লিখুন
7. **Review release** এবং **Start rollout** করুন

### Step 5: Internal Testing (Optional)
1. Play Console এ **Testing > Internal testing** যান
2. **Create new release** করুন
3. Testers email যোগ করুন
4. Testers কে link পাঠান

---

## 🔍 Pre-Deployment Checklist

### সাধারণ
- [x] App version সঠিক আছে: `1.0.0+2`
- [x] App name সঠিক: "Chef Starz"
- [x] Bundle ID সঠিক: `com.chefstarz.app`
- [x] App icon সেট করা আছে
- [ ] Privacy Policy URL প্রস্তুত (App Store/Play Store এর জন্য প্রয়োজন)
- [ ] App screenshots প্রস্তুত
- [ ] App description লেখা

### iOS Specific
- [x] Development Team সেট করা আছে
- [x] Permissions descriptions যোগ করা হয়েছে
- [ ] Xcode এ signing সেটআপ করা
- [ ] TestFlight এ app তৈরি করা হয়েছে

### Android Specific
- [x] Release signing configuration সেট করা আছে
- [ ] `key.properties` ফাইল তৈরি করা
- [ ] Keystore password নিরাপদে সংরক্ষণ করা
- [ ] Play Console এ app তৈরি করা হয়েছে

---

## 🧪 Testing Commands

### iOS Simulator এ রান করুন
```bash
flutter run -d "iPhone 15 Pro"
```

### Android Emulator এ রান করুন
```bash
flutter run -d emulator-5554
```

### Release mode এ test করুন
```bash
# iOS
flutter run --release -d <device_id>

# Android
flutter run --release -d <device_id>
```

### Build test করুন
```bash
# iOS
flutter build ios --release --no-codesign

# Android (without signing)
flutter build apk --release
```

---

## 🐛 Common Issues & Solutions

### iOS: "No signing certificate found"
**Solution**: Xcode এ Signing & Capabilities এ গিয়ে team সিলেক্ট করুন।

### Android: "Keystore file not found"
**Solution**: `key.properties` ফাইলে `storeFile` path সঠিক আছে কিনা চেক করুন।

### iOS: "Missing compliance"
**Solution**: App Store Connect এ export compliance information দিন।

### Android: "Upload failed"
**Solution**: Version code বাড়ান `pubspec.yaml` এ (যেমন: `1.0.0+3`)।

---

## 📞 Support

কোন সমস্যা হলে:
1. Flutter doctor চালান: `flutter doctor -v`
2. Clean build করুন: `flutter clean && flutter pub get`
3. Rebuild করুন

---

## 🔐 Security Notes

**কখনো git এ commit করবেন না:**
- ❌ `android/key.properties`
- ❌ `*.jks` (keystore files)
- ❌ Passwords বা API keys

**নিরাপদে রাখুন:**
- ✅ Keystore file backup
- ✅ Keystore passwords
- ✅ Apple Developer credentials
- ✅ Play Console credentials

---

## 📝 Version Update করার নিয়ম

`pubspec.yaml` এ version আপডেট করুন:
```yaml
version: 1.0.1+3
#        ^     ^
#        |     |
#        |     +-- Build number (প্রতি build এ বাড়ান)
#        +-------- Version name (feature update এ বাড়ান)
```

**Example:**
- Bug fix: `1.0.0+2` → `1.0.1+3`
- Minor update: `1.0.1+3` → `1.1.0+4`
- Major update: `1.1.0+4` → `2.0.0+5`

---

Good luck with your deployment! 🎉
