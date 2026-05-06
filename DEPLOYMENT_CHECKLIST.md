# ✅ Chef Starz - Deployment Checklist

## 🎉 সম্পন্ন কাজ (Completed)

### ✅ 1. Bundle Identifier আপডেট
- **iOS**: `com.chefstarz.app` ✓
- **Android**: `com.chefstarz.app` ✓
- **Status**: সম্পন্ন

### ✅ 2. iOS Permissions
- Camera Permission ✓
- Photo Library Permission ✓
- Photo Library Add Permission ✓
- Microphone Permission ✓
- **Status**: সম্পন্ন

### ✅ 3. Android Permissions
- Internet ✓
- Network State ✓
- Camera ✓
- Storage (Read/Write) ✓
- Media Images & Video (Android 13+) ✓
- **Status**: সম্পন্ন

### ✅ 4. Android Release Signing
- Signing configuration যোগ করা হয়েছে ✓
- Keystore support যোগ করা হয়েছে ✓
- **Status**: সম্পন্ন (key.properties তৈরি করতে হবে)

### ✅ 5. Security
- .gitignore আপডেট করা হয়েছে ✓
- Keystore files protected ✓
- **Status**: সম্পন্ন

---

## 📋 এখন যা করতে হবে (Next Steps)

### 🔐 Step 1: Android Keystore Setup (5 মিনিট)

আপনার কাছে ইতিমধ্যে keystore আছে: `Chef Starz-upload-keystore.jks`

**1.1 key.properties ফাইল তৈরি করুন:**
```bash
cd android
nano key.properties
```

**1.2 এই content যোগ করুন:**
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../Chef Starz-upload-keystore.jks
```

**1.3 Save করুন** (Ctrl+O, Enter, Ctrl+X)

---

### 📱 Step 2: iOS TestFlight Deployment (15 মিনিট)

**2.1 Xcode এ প্রজেক্ট খুলুন:**
```bash
open ios/Runner.xcworkspace
```

**2.2 Signing Setup:**
1. Runner target সিলেক্ট করুন
2. Signing & Capabilities ট্যাবে যান
3. Team verify করুন (93T4K6Y72D)
4. "Automatically manage signing" চেক করুন

**2.3 Archive তৈরি করুন:**
```bash
flutter build ipa
```

অথবা Xcode থেকে: **Product > Archive**

**2.4 TestFlight এ আপলোড:**
1. Archive সফল হলে Organizer window খুলবে
2. "Distribute App" ক্লিক করুন
3. "App Store Connect" সিলেক্ট করুন
4. "Upload" করুন

**2.5 App Store Connect এ:**
1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) এ যান
2. TestFlight ট্যাবে যান
3. Tester যোগ করুন
4. Build submit করুন

---

### 🤖 Step 3: Android Internal Testing (10 মিনিট)

**3.1 Release AAB তৈরি করুন:**
```bash
flutter build appbundle --release
```

**3.2 Play Console এ আপলোড:**
1. [play.google.com/console](https://play.google.com/console) এ যান
2. Testing > Internal testing যান
3. "Create new release" ক্লিক করুন
4. AAB আপলোড করুন: `build/app/outputs/bundle/release/app-release.aab`
5. Release notes লিখুন
6. "Review release" এবং "Start rollout"

**3.3 Testers যোগ করুন:**
1. Email list তৈরি করুন
2. Testers কে invite link পাঠান

---

## 🧪 Testing Commands

### Build Test করুন (Deploy করার আগে)

**iOS:**
```bash
# Clean build
flutter clean
flutter pub get

# Build test (no signing)
flutter build ios --release --no-codesign

# যদি সব ঠিক থাকে, তাহলে:
flutter build ipa
```

**Android:**
```bash
# Clean build
flutter clean
flutter pub get

# Build test
flutter build appbundle --release

# APK test করতে চাইলে:
flutter build apk --release
```

---

## 📊 Current App Info

| Property | Value |
|----------|-------|
| **App Name** | Chef Starz |
| **Bundle ID (iOS)** | com.chefstarz.app |
| **Package Name (Android)** | com.chefstarz.app |
| **Version** | 1.0.0 |
| **Build Number** | 2 |
| **Min iOS** | 13.0 |
| **Min Android SDK** | 21 (Android 5.0) |
| **Target Android SDK** | Latest |

---

## ⚠️ Important Notes

### iOS
- ✅ Development Team: 93T4K6Y72D (already set)
- ⚠️ App Store Connect এ app তৈরি করা আছে কিনা চেক করুন
- ⚠️ Privacy Policy URL প্রয়োজন হবে
- ⚠️ Screenshots প্রস্তুত রাখুন

### Android
- ⚠️ `key.properties` ফাইল তৈরি করতে হবে (Step 1)
- ⚠️ Keystore password নিরাপদে রাখুন
- ⚠️ Play Console এ app তৈরি করা আছে কিনা চেক করুন
- ⚠️ Privacy Policy URL প্রয়োজন হবে

### Both Platforms
- 📸 Screenshots (বিভিন্ন device size এর জন্য)
- 📝 App Description (English + অন্যান্য ভাষা)
- 🔒 Privacy Policy URL
- 📧 Support Email
- 🌐 Website URL (optional)

---

## 🐛 Troubleshooting

### "Keystore file not found"
```bash
# Check if keystore exists
ls -la "Chef Starz-upload-keystore.jks"

# Check key.properties path
cat android/key.properties
```

### "Signing certificate not found" (iOS)
```bash
# Open Xcode and check signing
open ios/Runner.xcworkspace
# Then: Runner > Signing & Capabilities
```

### Build fails
```bash
# Clean everything
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter pub get

# Try again
flutter build ipa  # iOS
flutter build appbundle --release  # Android
```

---

## 📞 Need Help?

1. **Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Check Dependencies:**
   ```bash
   flutter pub get
   flutter pub outdated
   ```

3. **Detailed Guide:**
   দেখুন: `DEPLOYMENT_GUIDE.md`

---

## 🎯 Quick Deploy Commands

### iOS TestFlight
```bash
flutter clean && flutter pub get && flutter build ipa
```

### Android Internal Testing
```bash
flutter clean && flutter pub get && flutter build appbundle --release
```

---

**সব ঠিক আছে! এখন আপনি deploy করতে পারবেন। Good luck! 🚀**
