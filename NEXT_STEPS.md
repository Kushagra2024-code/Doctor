# Quick Setup Checklist

## ⚠️ IMPORTANT: Complete These Steps Before Running

### 1. Configure Firebase (REQUIRED)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Firebase project
cd /home/kushagra/Documents/code/Doctor
flutterfire configure --project=doctor
```

This will automatically:
- Generate `lib/firebase_options.dart` with your actual credentials
- Configure Firebase for all platforms

### 2. Download Firebase Config Files

#### Android:
1. Go to https://console.firebase.google.com/
2. Select "doctor" project
3. Project Settings > Android app
4. Download `google-services.json`
5. Replace `android/app/google-services.json`

#### iOS:
1. Project Settings > iOS app
2. Download `GoogleService-Info.plist`
3. Replace `ios/Runner/GoogleService-Info.plist`

### 3. Enable Firebase Services
In Firebase Console:
- ✅ Authentication > Email/Password
- ✅ Firestore Database > Create database

### 4. Add Gemini API Key
1. Get key from: https://makersuite.google.com/app/apikey
2. Edit `lib/main.dart` line 54
3. Uncomment and add: `_geminiService.initialize('YOUR_KEY');`

### 5. Run the App
```bash
flutter pub get
flutter run
```

## Current Status
✅ Flutter project created
✅ Dependencies added
✅ Gradle configured
✅ Service classes created
✅ Main app structure ready

⏳ Waiting for:
- Firebase configuration (firebase_options.dart)
- Firebase config files (google-services.json, GoogleService-Info.plist)
- Gemini API key

## Need Help?
See SETUP_GUIDE.md for detailed instructions
