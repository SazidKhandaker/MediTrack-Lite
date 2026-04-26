class AppText {

// profile page jonno
  static String settings(String lang) {
    return lang == 'bn' ? "সেটিংস" : "Settings";
  }

  static String profile(String lang) {
    return lang == 'bn' ? "প্রোফাইল" : "Profile";
  }

  static String about(String lang) {
    return lang == 'bn' ? "আমার সম্পর্কে" : "About Me";
  }

  static String save(String lang) {
    return lang == 'bn' ? "সংরক্ষণ করুন" : "Save";
  }

  static String language(String lang) {
    return lang == 'bn' ? "ভাষা" : "Language";
  }

  static String noBio(String lang) {
    return lang == 'bn' ? "কোনো তথ্য যোগ করা হয়নি" : "No bio added";
  }

  static String updateProfile(String lang) {
    return lang == 'bn' ? "প্রোফাইল আপডেট করুন" : "Update Profile";
  }
  static String editProfile(String lang) {
    return lang == 'bn' ? "প্রোফাইল সম্পাদনা" : "Edit Profile";
  }

  static String notifications(String lang) {
    return lang == 'bn' ? "নোটিফিকেশন" : "Notifications";
  }

  static String theme(String lang) {
    return lang == 'bn' ? "থিম" : "Theme";
  }

  static String lightMode(String lang) {
    return lang == 'bn' ? "লাইট মোড" : "Light Mode";
  }

  static String darkMode(String lang) {
    return lang == 'bn' ? "ডার্ক মোড" : "Dark Mode";
  }
  static String logout(String lang) {
    return lang == 'bn' ? "লগ আউট" : "Logout";
  }
  //editpage jonno
  static String fullName(String lang) {
    return lang == 'bn' ? "পূর্ণ নাম" : "Full Name";
  }

  static String email(String lang) {
    return lang == 'bn' ? "ইমেইল" : "Email";
  }
  static String updateProfilePicture(String lang) {
    return lang == 'bn'
        ? "প্রোফাইল ছবি আপডেট করুন"
        : "Update Profile Picture";
  }
  //add page
  static String addMedicine(String lang) {
    return lang == 'bn' ? "ওষুধ যোগ করুন" : "Add Medicine";
  }

  static String addMedicineDetails(String lang) {
    return lang == 'bn'
        ? "আপনার ওষুধের তথ্য দিন"
        : "Add your medicine details";
  }

  static String medicineName(String lang) {
    return lang == 'bn' ? "ওষুধের নাম" : "Medicine Name";
  }

  static String instruction(String lang) {
    return lang == 'bn' ? "নির্দেশনা" : "Instruction";
  }

  static String beforeMeal(String lang) {
    return lang == 'bn' ? "খাওয়ার আগে" : "Before Meal";
  }

  static String afterMeal(String lang) {
    return lang == 'bn' ? "খাওয়ার পরে" : "After Meal";
  }

  static String selectTime(String lang) {
    return lang == 'bn' ? "সময় নির্বাচন করুন" : "Select Time";
  }

  static String selectDate(String lang) {
    return lang == 'bn' ? "তারিখ নির্বাচন করুন" : "Select Date";
  }

  static String saveMedicine(String lang) {
    return lang == 'bn' ? "সংরক্ষণ করুন" : "Save Medicine";
  }

  static String fillAllFields(String lang) {
    return lang == 'bn'
        ? "সব তথ্য পূরণ করুন"
        : "Fill all fields";
  }

  static String saved(String lang) {
    return lang == 'bn'
        ? "ওষুধ সংরক্ষণ করা হয়েছে"
        : "Medicine Saved";
  }


  // 🔝 Header
  static String reminder(String lang) {
  return lang == 'bn'
  ? "আপনার ওষুধের রিমাইন্ডার"
      : "Your Medicines Reminder";
  }

  // 📊 Progress
  static String progress(String lang) {
  return lang == 'bn'
  ? "আজকের অগ্রগতি"
      : "Today's Progress";
  }

  // ❌ Empty UI
  static String noMedicine(String lang) {
  return lang == 'bn'
  ? "আজ কোনো ওষুধ যোগ করা হয়নি"
      : "No Medicines Today";
  }

  // 🔘 Buttons
  static String taken(String lang) {
  return lang == 'bn'
  ? "গ্রহণ করা হয়েছে"
      : "Taken";
  }

  static String missed(String lang) {
  return lang == 'bn'
  ? "মিস হয়েছে"
      : "Missed";
  }

  // ⏰ Next dose
  static String nextDose(String lang) {
  return lang == 'bn'
  ? "পরবর্তী ডোজ"
      : "Next dose";
  }

  // ➕ Add hint
  static String addMedicineHint(String lang) {
  return lang == 'bn'
  ? "নতুন ওষুধ যোগ করতে + চাপুন"
      : "Tap + to add your medicine";
  }
  static String meal(String lang, String meal) {

    if (lang == 'bn') {
      if (meal == "Before Meal") return "খাওয়ার আগে";
      if (meal == "After Meal") return "খাওয়ার পরে";
    }

    return meal; // default English
  }
  static String medicineDetails(String lang) {
    return lang == 'bn' ? "ওষুধের বিস্তারিত" : "Medicine Details";
  }

  static String remove(String lang) {
    return lang == 'bn' ? "ডিলিট" : "Remove";
  }

  static String description(String lang) {
    return lang == 'bn'
        ? "ওষুধের বিস্তারিত তথ্য"
        : "Medicine description";
  }

  static String timeLabel(String lang) {
    return lang == 'bn' ? "সময়" : "Time";
  }

  static String statusLabel(String lang) {
    return lang == 'bn' ? "অবস্থা" : "Status";
  }

  static String takenStatus(String lang) {
    return lang == 'bn' ? "নেওয়া হয়েছে" : "Taken";
  }

  static String notTakenStatus(String lang) {
    return lang == 'bn' ? "নেওয়া হয়নি" : "Not Taken";
  }

  static String editSchedule(String lang) {
    return lang == 'bn' ? "সময় পরিবর্তন" : "Edit Schedule";
  }
  static String history(String lang){
    return lang== 'bn'?    "ইতিহাস" : "history" ;
  }
  }
