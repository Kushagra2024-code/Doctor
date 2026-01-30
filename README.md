# 🧠📱 AI Medical Voice Agent App

A comprehensive Flutter application that implements an AI-powered medical voice assistant with real-time speech-to-text, AI responses from Google Gemini, multiple doctor specializations, medical report generation, and comprehensive safety features.

## ⚠️ IMPORTANT MEDICAL DISCLAIMER

**THIS APPLICATION IS FOR EDUCATIONAL PURPOSES ONLY**

- This app does NOT provide medical advice, diagnosis, or treatment
- It is NOT a substitute for professional medical consultation
- Always consult with qualified healthcare providers for medical concerns
- In case of emergency, call 911 or your local emergency services immediately
- The AI responses are informational and should not be relied upon for medical decisions

## ✨ Features

### 🎯 Core Functionality
- **Voice-Based Consultations**: Real-time speech-to-text using Google Speech Recognition
- **AI Doctor Responses**: Powered by Google Gemini API (free tier)
- **Multiple Doctor Specializations**:
  - 👨‍⚕️ General Physician (FREE)
  - ❤️ Cardiologist (Premium - Locked)
  - 👶 Pediatrician (Premium - Locked)
  - 🧠 Mental Health Assistant (Premium - Locked)
- **Text-to-Speech**: Natural voice responses using Flutter TTS
- **Medical Reports**: AI-generated consultation summaries with symptoms, advice, and warnings
- **Emergency Detection**: Automatic detection of emergency keywords with immediate safety responses

### 🔐 Authentication & Security
- Firebase Authentication (FREE tier)
- Email/Password registration and login
- Anonymous login fallback
- Secure user session management

### 💾 Data Storage
- Cloud Firestore (FREE tier) for report storage
- User-specific report history
- Persistent conversation data

### 🎨 User Interface
- Material 3 design
- Dark mode support
- Animated microphone button with listening indicator
- Real-time transcript display
- Professional report layout

## 🛠️ Tech Stack

### FREE Services Only ✅
- **Flutter**: Latest stable SDK
- **Google Gemini API**: Free tier (gemini-pro model)
- **Google Speech-to-Text**: Free quota via speech_to_text package
- **Firebase Authentication**: FREE tier
- **Cloud Firestore**: FREE tier
- **Flutter TTS**: Free, open-source

### Key Dependencies
```yaml
dependencies:
  flutter_sdk: latest
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  google_generative_ai: ^0.4.6
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.0
  permission_handler: ^11.3.1
  flutter_dotenv: ^5.2.1
  provider: ^6.1.2
  http: ^1.2.2
  intl: ^0.19.0
  uuid: ^4.5.1
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget with theming
├── config/
│   ├── env.dart                # Environment variable loader
│   └── gemini_config.dart      # Gemini API configuration
├── data/
│   └── doctors.dart            # Doctor definitions with system prompts
├── models/
│   ├── doctor.dart             # Doctor model
│   └── report.dart             # Medical report model
├── services/
│   ├── auth_service.dart       # Firebase authentication
│   ├── speech_service.dart     # Speech-to-text service
│   ├── gemini_service.dart     # AI conversation service
│   ├── tts_service.dart        # Text-to-speech service
│   └── report_service.dart     # Report generation & storage
├── widgets/
│   ├── doctor_card.dart        # Doctor selection card
│   ├── mic_button.dart         # Animated microphone button
│   └── transcript_view.dart    # Conversation transcript display
└── screens/
    ├── splash_screen.dart      # Initial loading screen
    ├── login_screen.dart       # Authentication screen
    ├── doctor_select_screen.dart  # Doctor selection
    ├── consultation_screen.dart   # Voice consultation
    └── report_screen.dart      # Medical report display
```

## 🚀 Setup Instructions

### Prerequisites
1. **Flutter SDK**: Install from [flutter.dev](https://flutter.dev)
   ```bash
   flutter --version  # Verify installation
   ```

2. **Firebase Project**: 
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project (FREE plan)
   - Enable Authentication (Email/Password and Anonymous)
   - Enable Cloud Firestore
   - Download configuration files (already configured in this project)

3. **Gemini API Key**:
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a FREE API key
   - No credit card required!

### Installation Steps

1. **Clone or navigate to the project directory**
   ```bash
   cd /home/kushagra/Documents/code/Doctor
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Edit the `.env` file in the root directory:
   ```env
   # REQUIRED: Get your free API key from https://makersuite.google.com/app/apikey
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   
   # OPTIONAL: AssemblyAI key (not needed, we use Google Speech-to-Text)
   ASSEMBLY_AI_KEY=optional
   ```

4. **Verify Firebase configuration**
   
   The project already has Firebase configured. If you want to use your own Firebase project:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure your Firebase project
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For Web
   flutter run -d chrome
   
   # For specific device
   flutter devices
   flutter run -d <device_id>
   ```

## 📱 Platform Support

### ✅ Fully Supported
- **Android**: Primary target, all features work
- **Web**: Compatible, some permissions may require browser setup

### ⚠️ Requires Additional Setup
- **iOS**: Requires Xcode and iOS provisioning
- **Windows/Linux/macOS**: May need platform-specific microphone permissions

## 🎮 How to Use

### 1. First Launch
- The app opens to a splash screen
- If not logged in, you'll see the login screen
- Create an account with email/password or continue as guest

### 2. Select a Doctor
- Choose from available AI doctors
- Only "General Physician" is free (demo restriction)
- Premium doctors show as locked

### 3. Start Consultation
- Tap the microphone button to start speaking
- Speak your health concerns clearly
- The AI doctor will respond with advice
- Conversation is displayed in real-time

### 4. Emergency Detection
If you mention emergency keywords like:
- "chest pain"
- "can't breathe"
- "suicidal thoughts"
- "severe bleeding"

The app immediately displays emergency contact information.

### 5. End Consultation
- Tap the "Stop" button in the app bar
- A medical report is automatically generated
- View your consultation summary, symptoms, and advice

### 6. View Reports
- Reports are saved to your account
- Access past consultations anytime
- Share or export reports (feature placeholder)

## 🔒 Privacy & Security

- **No Payment Data**: No credit cards or paid services
- **Firebase Security**: User authentication and data isolation
- **Local Processing**: Speech recognition happens on-device when possible
- **Encrypted Storage**: Firebase handles encryption
- **No Personal Health Data**: App is educational only

## 🐛 Troubleshooting

### Microphone Permission Denied
```
Solution: Enable microphone permission in system settings
- Android: Settings > Apps > Doctor > Permissions > Microphone
- Web: Browser will prompt for permission
```

### Gemini API Error
```
Error: "API key not configured" or "Invalid API key"
Solution: 
1. Get a free API key from https://makersuite.google.com/app/apikey
2. Add it to .env file
3. Restart the app
```

### Speech Recognition Not Working
```
Solution: Check internet connection
- Google Speech-to-Text requires internet
- Ensure stable network connection
```

### Firebase Error
```
Error: "Firebase initialization failed"
Solution: 
1. Check firebase_options.dart exists
2. Verify Firebase project is active
3. Enable Authentication and Firestore in Firebase Console
```

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 🏗️ Architecture

### Service Layer
- **AuthService**: Handles user authentication
- **SpeechService**: Converts speech to text
- **GeminiService**: AI conversation and report generation
- **TtsService**: Converts text to speech
- **ReportService**: Saves and retrieves medical reports

### State Management
- Simple setState for most screens
- StreamBuilder for authentication state
- Service-based architecture for clean separation

### AI System Prompts
Each doctor has a specialized system prompt that:
- Defines their medical specialty
- Sets conversation style
- Enforces safety rules (no diagnosis, no prescriptions)
- Includes emergency detection guidelines

## 📊 Firebase Firestore Structure

```
reports/
  ├── {reportId}/
  │   ├── id: string
  │   ├── userId: string
  │   ├── doctorId: string
  │   ├── doctorName: string
  │   ├── timestamp: timestamp
  │   ├── summary: string
  │   ├── symptoms: array<string>
  │   ├── possibleCauses: array<string>
  │   ├── advice: array<string>
  │   ├── emergencyWarning: string
  │   └── fullTranscript: string
```

## 🔮 Future Enhancements (Not Implemented)

These features would require paid services:
- ❌ Real payment system (would need Stripe/PayPal)
- ❌ Advanced AI models (would need paid API)
- ❌ Cloud storage for audio files (would exceed free tier)
- ❌ Push notifications (requires paid plan)
- ❌ SMS alerts (requires Twilio/paid service)

## 🤝 Contributing

This is an educational project demonstrating:
- Flutter development best practices
- AI integration with free APIs
- Voice interaction implementation
- Firebase authentication and database
- Medical safety considerations

Feel free to fork and enhance for learning purposes!

## 📄 License

This project is for educational purposes. Medical advice features are demonstration only.

## 🙏 Acknowledgments

- **Google Gemini**: Free AI API
- **Firebase**: Free backend services
- **Flutter**: Cross-platform framework
- **Flutter TTS**: Open-source text-to-speech
- **Speech-to-Text**: Google's free speech recognition

## 📞 Support

For technical issues:
1. Check this README
2. Review error messages in console
3. Verify all API keys are configured
4. Ensure all dependencies are installed

For medical emergencies:
- **Call 911** (US)
- **Call 999** (UK)
- **Call 112** (EU)
- Or your local emergency number

---

**Remember**: This app is a demonstration tool for educational purposes only. Always consult real healthcare professionals for medical advice.

Built with ❤️ using Flutter and FREE services only!
