class Languages {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Navigation
      'home': 'Home',
      'history': 'History',
      'water': 'Water',
      'help': 'Help',
      'steps': 'Steps',
      'resources': 'Resources',
      'profile': 'Profile',

      // Home Tab
      'daily_summary': 'Daily Summary',
      'calories': 'Calories',
      'water_intake': 'Water',
      'steps_count': 'Steps',
      'quick_actions': 'Quick Actions',
      'complete_profile': 'Complete Profile',
      'complete_profile_title': 'Complete Your Health Profile',
      'complete_profile_desc':
          'To get the most out of your nutrition tracking experience, please complete your health profile. This will help us provide personalized recommendations and track your progress effectively.',

      // Auth
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'sign_up': 'Sign Up',
      'sign_in': 'Sign In',

      // Health Profile
      'health_profile': 'Health Profile',
      'personal_info': 'Personal Information',
      'age': 'Age',
      'gender': 'Gender',
      'weight': 'Weight (kg)',
      'height': 'Height (cm)',
      'activity_level': 'Activity Level',
      'daily_goals': 'Daily Goals',
      'daily_calories': 'Daily Calories',
      'daily_water': 'Daily Water (ml)',
      'daily_steps': 'Daily Steps',
      'save_profile': 'Save Profile',

      // Water Intake
      'add_water': 'Add Water',
      'water_amount': 'Water Amount (L)',
      'today_water': 'Today\'s Water',
      'water_history': 'Water History',
      'add_water_intake': 'Add Water Intake',
      'add_custom_amount': 'Add Custom Amount',
      'amount_ml': 'Amount (ml)',
      'please_enter_amount': 'Please enter an amount',
      'please_enter_valid_amount': 'Please enter a valid amount',
      'delete_entry': 'Delete Entry',
      'delete_water_confirmation':
          'Are you sure you want to delete this water intake entry?',
      'water_added_success': 'Water intake added successfully',
      'entry_deleted_success': 'Entry deleted successfully',
      'recent_entries': 'Recent Entries',
      'no_entries_yet': 'No entries yet',

      // Food Entry
      'log_meal': 'Log Meal',
      'food_name': 'Food Name',
      'food_name_somali': 'Food Name (Somali)',
      'portion_size': 'Portion Size',
      'nutrition_info': 'Nutrition Information',
      'add_food': 'Add Food',
      'meal_history': 'Meal History',
      'no_meals': 'No meals logged yet',
      'start_tracking':
          'Start tracking your meals to see your nutrition history',
      'take_upload_photo': 'Take or Upload Food Photo',
      'take_photo': 'Take Photo',
      'upload': 'Upload',
      'analyze_food': 'Analyze Food',
      'analyzed_food_items': 'Analyzed Food Items',
      'detailed_nutrition': 'Detailed Nutrition',
      'macronutrients': 'Macronutrients',
      'vitamins': 'Vitamins',
      'minerals': 'Minerals',
      'camera_permission_required': 'Camera Permission Required',
      'camera_permission_message':
          'Camera access is required to take photos. Please enable it in settings.',
      'photo_library_permission_required': 'Photo Library Permission Required',
      'photo_library_permission_message':
          'Photo library access is required to select photos. Please enable it in settings.',
      'permission_denied':
          'Permission denied. Please grant camera/gallery access in settings.',
      'failed_pick_image': 'Failed to pick image',
      'unexpected_error': 'An unexpected error occurred',
      'please_select_image': 'Please select an image first',
      'no_food_detected': 'No food items were detected in the image',
      'food_analyzed_success': 'Food items analyzed successfully',
      'unknown': 'Unknown',
      'somali': 'Somali',
      'portion': 'Portion',

      // Step Counter
      'step_counter': 'Step Counter',
      'today_steps': 'Today\'s Steps',
      'step_goal': 'Step Goal',
      'today_progress': 'Today\'s Progress',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'walking_tips': 'Walking Tips',
      'take_short_walks': 'Take short walks during breaks',
      'use_stairs': 'Use stairs instead of elevators',
      'park_further': 'Park further from your destination',

      // Help
      'help_support': 'Help & Support',
      'live_support': 'Live Support',
      'online': 'Online',
      'type_message': 'Type your message...',
      'connecting_whatsapp':
          'Connecting you to our support team on WhatsApp...',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'of': 'of',
      'target': 'Target',
      'current': 'Current',
      'retry': 'Retry',
      'logout': 'Logout',
      'logout_confirmation': 'Are you sure you want to logout?',
      'username': 'Username',
      'phone_number': 'Phone Number',
      'nutrition_goals': 'Nutrition Goals',
      'settings': 'Settings',
      'complete_profile_message':
          'Please complete your health profile to get personalized nutrition recommendations.',
      'articles': 'Articles',
      'videos': 'Videos',
      'search_resources': 'Search resources...',
      'all': 'All',
      'no_articles_available': 'No articles available',
      'no_videos_available': 'No videos available',
      'no_articles_found': 'No articles found for',
      'no_videos_found': 'No videos found for',
      'read_article': 'Read Article',
      'could_not_open_link': 'Could not open the link',

      // Gender options
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',

      // Activity levels
      'sedentary': 'Sedentary',
      'lightly_active': 'Lightly Active',
      'moderately_active': 'Moderately Active',
      'very_active': 'Very Active',
      'extremely_active': 'Extremely Active',

      // Goal types
      'weight_loss': 'Weight Loss',
      'maintenance': 'Maintenance',
      'muscle_gain': 'Muscle Gain',

      // Error and Success Messages
      'error_initializing_step_counter': 'Error initializing step counter',
      'error_refreshing_data': 'Error refreshing data',
      'food_entry_deleted_success': 'Food entry deleted successfully',
      'failed_delete_food_entry': 'Failed to delete food entry',
    },
    'so': {
      // Navigation
      'home': 'Bogga Hore',
      'history': 'Taariikh',
      'water': 'Biyo',
      'help': 'Caawimaad',
      'steps': 'Tallaabooyin',
      'resources': 'Kheyraad',
      'profile': 'Xogta',

      // Home Tab
      'daily_summary': 'Warbixin Maalinle',
      'calories': 'Kalooriyo',
      'water_intake': 'Cabitaanka Biyaha',
      'steps_count': 'Tallaabooyin',
      'quick_actions': 'Hawlaha Degdegga',
      'complete_profile': 'Buuxi Xogta',
      'complete_profile_title': 'Buuxi Xogta Caafimaadkaaga',
      'complete_profile_desc':
          'Si aad uga faa’iidaysato raadinta cuntadaada, fadlan buuxi xogta caafimaadkaaga. Tani waxay kaa caawin doontaa inaan ku siino talooyin gaar ah oo kugu habboon isla markaana aan si fiican ula socono horumarkaaga.',

      // Auth
      'login': 'Gal',
      'register': 'Isdiiwaangeli',
      'email': 'Email',
      'password': 'Furaha Sirta',
      'confirm_password': 'Xaqiiji Furaha Sirta',
      'forgot_password': 'Ma hilmaantay furaha?',
      'dont_have_account': 'Akoon ma lihid?',
      'already_have_account': 'Hore ayaad u leedahay akoon?',
      'sign_up': 'Isdiiwaangeli',
      'sign_in': 'Gal',

      // Health Profile
      'health_profile': 'Xogta Caafimaadka',
      'personal_info': 'Macluumaad Shakhsiyeed',
      'age': 'Da’da',
      'gender': 'Jinsi',
      'weight': 'Miisaanka (kg)',
      'height': 'Dhererka (cm)',
      'activity_level': 'Heerka Firfircoonida',
      'daily_goals': 'Hadafyada Maalinlaha',
      'daily_calories': 'Kalooriyada Maalinlaha',
      'daily_water': 'Biyaha Maalinlaha (ml)',
      'daily_steps': 'Tallaabooyinka Maalinlaha',
      'save_profile': 'Kaydi Xogta',

      // Water Intake
      'add_water': 'Ku Dar Biyo',
      'water_amount': 'Qaddarka Biyaha (L)',
      'today_water': 'Biyaha Maanta',
      'water_history': 'Taariikhda Biyaha',
      'add_water_intake': 'Ku Dar Cabitaanka Biyaha',
      'add_custom_amount': 'Ku Dar Qiyaas Gaar ah',
      'amount_ml': 'Qaddarka (ml)',
      'please_enter_amount': 'Fadlan geli qaddar',
      'please_enter_valid_amount': 'Fadlan geli qaddar sax ah',
      'delete_entry': 'Tirtir Qoritaanka',
      'delete_water_confirmation':
          'Ma hubtaa inaad tirtirto qoritaanka cabitaanka biyaha?',
      'water_added_success': 'Cabitaanka biyaha si guul leh ayaa loo daray',
      'entry_deleted_success': 'Qoritaanka si guul leh ayaa loo tirtiray',
      'recent_entries': 'Qoritaannadii Ugu Dambeeyay',
      'no_entries_yet': 'Weli qoritaan ma jiro',

      // Food Entry
      'log_meal': 'Qor Cunto',
      'food_name': 'Magaca Cuntada',
      'food_name_somali': 'Magaca Cuntada (Af-Soomaali)',
      'portion_size': 'Qiyaasta Qaybta',
      'nutrition_info': 'Macluumaadka Nafaqada',
      'add_food': 'Ku Dar Cunto',
      'meal_history': 'Taariikhda Cuntada',
      'no_meals': 'Weli cunto lama qorin',
      'start_tracking':
          'Bilow qorista cuntada si aad u aragto taariikhda nafaqadaada',
      'take_upload_photo': 'Qaado ama Soo geli Sawirka Cuntada',
      'take_photo': 'Qaado Sawir',
      'upload': 'Soo geli',
      'analyze_food': 'Falanqee Cuntada',
      'analyzed_food_items': 'Cuntooyinka la Falanqeeyay',
      'detailed_nutrition': 'Nafaqo Faahfaahsan',
      'macronutrients': 'Nafaqooyinka Waaweyn',
      'vitamins': 'Fiitamiinnada',
      'minerals': 'Macdanta',
      'camera_permission_required':
          'Ogolaanshaha Kaamerada ayaa loo baahan yahay',
      'camera_permission_message':
          'Si aad u qaaddo sawirro, ogolaanshaha kaamerada ayaa loo baahan yahay. Fadlan ka daar dejinta.',
      'photo_library_permission_required':
          'Ogolaanshaha Maktabadda Sawirrada ayaa loo baahan yahay',
      'photo_library_permission_message':
          'Si aad u doorato sawirro, ogolaanshaha maktabadda sawirrada ayaa loo baahan yahay. Fadlan ka daar dejinta.',
      'permission_denied':
          'Ogolaanshaha waa la diiday. Fadlan ka sii oggolow kaamera/galeri dejinta.',
      'failed_pick_image': 'Doorashada sawirka way fashilantay',
      'unexpected_error': 'Khalad lama filaan ah ayaa dhacay',
      'please_select_image': 'Fadlan marka hore dooro sawir',
      'no_food_detected': 'Cunto lagama helin sawirka',
      'food_analyzed_success': 'Cuntooyinka si guul leh ayaa loo falanqeeyay',
      'unknown': 'Aan la garan',
      'somali': 'Soomaali',
      'portion': 'Qayb',

      // Step Counter
      'step_counter': 'Tiriyaha Tallaabooyinka',
      'today_steps': 'Tallaabooyinka Maanta',
      'step_goal': 'Hadafka Tallaabooyinka',
      'today_progress': 'Horumarka Maanta',
      'completed': 'Dhameystiran',
      'in_progress': 'progress',
      'walking_tips': 'Talooyin Socod',
      'take_short_walks': 'Qaado socod gaaban inta nasashada',
      'use_stairs': 'Isticmaal jaranjaro halkii aad ka raaci lahayd wiish',
      'park_further': 'Gaadhiga ka dhig meel ka fog goobta aad u socoto',

      // Help
      'help_support': 'Caawimaad & Taageero',
      'live_support': 'Taageero Toos ah',
      'online': 'Online',
      'type_message': 'Qor fariintaada...',
      'connecting_whatsapp':
          'Kugu xiriirinaynaa kooxda taageerada ee WhatsApp...',

      // Common
      'save': 'Kaydi',
      'cancel': 'Jooji',
      'delete': 'Tirtir',
      'edit': 'Wax ka beddel',
      'loading': 'Waxaa la soo gelinayaa...',
      'error': 'Khalad',
      'success': 'Guul',
      'of': 'ka mid ah',
      'target': 'Hadaf',
      'current': 'Hadda',
      'retry': 'Dib u day',
      'logout': 'Ka Bax',
      'logout_confirmation': 'Ma hubtaa inaad ka baxeyso?',
      'username': 'Magaca Isticmaalaha',
      'phone_number': 'Lambarka Taleefanka',
      'nutrition_goals': 'Hadafyada Nafaqada',
      'settings': 'Dejinta',
      'complete_profile_message':
          'Fadlan buuxi xogta caafimaadkaaga si aad u hesho talooyin nafaqo oo kugu habboon.',
      'articles': 'Maqaallo',
      'videos': 'Fiidiyowyo',
      'search_resources': 'Raadi kheyraadka...',
      'all': 'Dhammaan',
      'no_articles_available': 'Maqaallo ma jiraan',
      'no_videos_available': 'Fiidiyowyo ma jiraan',
      'no_articles_found': 'Maqaallo lama helin',
      'no_videos_found': 'Fiidiyowyo lama helin',
      'read_article': 'Akhri Maqaal',
      'could_not_open_link': 'Isku xirka lama furin',

      // Gender options
      'male': 'Lab',
      'female': 'Dhedig',
      'other': 'Kale',

      // Activity levels
      'sedentary': 'Fadhi Badan',
      'lightly_active': 'Firfircoon Yar',
      'moderately_active': 'Firfircoon Dhexe',
      'very_active': 'Firfircoon Badan',
      'extremely_active': 'Firfircoon Aad u Badan',

      // Goal types
      'weight_loss': 'Hoos u dhig miisaanka',
      'maintenance': 'Ilaalinta',
      'muscle_gain': 'Kordhinta muruqa',

      // Error and Success Messages
      'error_initializing_step_counter':
          'Khalad ka dhacay bilowga tiirka tallaabooyin',
      'error_refreshing_data': 'Khalad ka dhacay cusboonaysinta xogta',
      'food_entry_deleted_success':
          'Qoritaanka cuntada si guul leh ayaa loo tirtiray',
      'failed_delete_food_entry': 'Qoritaanka cuntada lama tirtiro',
    },
  };

  static String getText(String key, String language) {
    return _translations[language]?[key] ?? key;
  }

  static List<String> getSupportedLanguages() {
    return _translations.keys.toList();
  }
}
