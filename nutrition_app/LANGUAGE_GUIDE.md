# Language System Guide

This app supports both English and Somali languages. Here's how to use the language system:

## How to Use

### 1. In any screen/widget, import the language provider:
```dart
import 'package:nutrition_app/providers/language_provider.dart';
```

### 2. Access the language provider in your widget:
```dart
// Using Consumer
Consumer<LanguageProvider>(
  builder: (context, languageProvider, child) {
    return Text(languageProvider.getText('home'));
  },
)

// Or using context.watch
final languageProvider = context.watch<LanguageProvider>();
Text(languageProvider.getText('home'));
```

### 3. Use the getText method to get translated text:
```dart
languageProvider.getText('home') // Returns 'Home' or 'Homeka'
languageProvider.getText('calories') // Returns 'Calories' or 'Kalooriyada'
```

## Available Language Keys

### Navigation
- `home` - Home / Homeka
- `history` - History / Taariikhda
- `water` - Water / Biyaha
- `help` - Help / Caawimaad
- `steps` - Steps / Tallaabooyin
- `resources` - Resources / Kheyraadka
- `profile` - Profile / Profileka

### Home Tab
- `daily_summary` - Daily Summary / Soo koobida maalintii
- `calories` - Calories / Kalooriyada
- `water_intake` - Water / Biyaha
- `steps_count` - Steps / Tallaabooyin
- `quick_actions` - Quick Actions / Ficilada degdega ah
- `log_meal` - Log Meal / Qor Cunto
- `complete_profile` - Complete Profile / Dhammeey Profileka

### Auth
- `login` - Login / Galitaanka
- `register` - Register / Diiwaangelinta
- `email` - Email / Emailka
- `password` - Password / Furaha
- `confirm_password` - Confirm Password / Xaqiiji Furaha

### Common
- `save` - Save / Kaydi
- `cancel` - Cancel / Jooji
- `delete` - Delete / Tir
- `edit` - Edit / Wax ka beddel
- `loading` - Loading... / La soo dejiyaa...
- `error` - Error / Khalad
- `success` - Success / Guul
- `of` - of / ka

## Adding New Translations

### 1. Add the key to the English translations in `lib/utils/languages.dart`:
```dart
'en': {
  // ... existing translations
  'new_key': 'English Text',
},
```

### 2. Add the Somali translation:
```dart
'so': {
  // ... existing translations
  'new_key': 'Somali Text',
},
```

## Language Toggle

The language can be toggled using the language button in the dashboard screen. The current language is saved automatically and will persist between app sessions.

## Current Language

You can check the current language:
```dart
final currentLanguage = languageProvider.currentLanguage; // 'en' or 'so'
```

## Toggle Language

You can programmatically toggle the language:
```dart
languageProvider.toggleLanguage(); // Switches between 'en' and 'so'
```

## Set Specific Language

You can set a specific language:
```dart
languageProvider.setLanguage('so'); // Set to Somali
languageProvider.setLanguage('en'); // Set to English
```
