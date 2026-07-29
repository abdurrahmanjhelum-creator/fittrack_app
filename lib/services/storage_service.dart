// 📁 services/storage_service.dart
//
// YEH KYA HAI: Ye file data ko save aur load karne ke functions provide karti hai
//
// STORAGE KYA HAI: shared_preferences use karte hain
// Ye phone mein ek file mein data store karta hai
// App band karne ke baad bhi data safe rehta hai

import 'dart:convert'; // JSON encode/decode ke liye
import 'package:shared_preferences/shared_preferences.dart'; // Local storage package
import '../models/workout_model.dart'; // Humara Workout model

class StorageService {
  // 🔹 CONSTANTS - Keys jo hum shared_preferences mein use karenge
  // Ye keys identify karti hain ke kaunsa data kahan store hai
  static const String _workoutsKey = 'workouts'; // Sab workouts store hain is key par
  static const String _userNameKey = 'userName'; // User name store hai is key par
  static const String _darkModeKey = 'darkMode'; // Dark mode setting is key par

  // ============================================================
  // SECTION 1: WORKOUTS RELATED FUNCTIONS
  // ============================================================

  // 🔹 FUNCTION 1: loadWorkouts() - Sab workouts load karein
  //
  // KYA KARTA HAI: shared_preferences se workouts ki JSON string read karta hai
  // phir usko List<Workout> mein convert karta hai
  //
  // KAISE USE HOGA: Home screen par jab app open ho to ye function call hoga
  static Future<List<Workout>> loadWorkouts() async {
    // 🔹 Step 1: shared_preferences ka instance lein
    // SharedPreferences ek class hai jo phone ki storage access karti hai
    final prefs = await SharedPreferences.getInstance();

    // 🔹 Step 2: String read karein using key
    // getString('workouts') - workouts key par jo string hai wo le lo
    final String? jsonString = prefs.getString(_workoutsKey);

    // 🔹 Step 3: Agar kuch nahi mila to empty list return karein
    // Pehli baar app open ho to kuch nahi hoga to empty list de do
    if (jsonString == null) {
      return [];
    }

    // 🔹 Step 4: Agar string mil gayi to usko decode karein
    try {
      // jsonDecode - string ko List mein convert karein
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 🔹 Step 5: Har item ko Workout model mein convert karein
      // map() - har element par function apply karo
      // .toList() - result ko list mein convert karo
      return jsonList.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      // Agar error aaye to empty list return karo
      return [];
    }
  }

  // 🔹 FUNCTION 2: saveWorkouts() - Sab workouts save karein
  //
  // KYA KARTA HAI: List<Workout> ko JSON string mein convert karta hai
  // phir shared_preferences mein store kar deta hai
  static Future<void> saveWorkouts(List<Workout> workouts) async {
    // 🔹 Step 1: shared_preferences ka instance lein
    final prefs = await SharedPreferences.getInstance();

    // 🔹 Step 2: Workouts ki list ko JSON string mein convert karein
    // workouts.map((w) => w.toJson()) - har workout ko JSON mein convert
    // jsonEncode - list ko string mein convert
    final String jsonString = jsonEncode(workouts.map((w) => w.toJson()).toList());

    // 🔹 Step 3: String ko shared_preferences mein save karein
    // setString('workouts', jsonString) - workouts key par ye string save karo
    await prefs.setString(_workoutsKey, jsonString);
  }

  // 🔹 FUNCTION 3: addWorkout() - Naya workout add karein
  //
  // KYA KARTA HAI: Pehle existing workouts load karta hai
  // phir naya workout add karta hai
  // phir wapas save kar deta hai
  static Future<void> addWorkout(Workout workout) async {
    // 🔹 Step 1: Existing workouts load karein
    final workouts = await loadWorkouts();

    // 🔹 Step 2: Naya workout add karein
    workouts.add(workout);

    // 🔹 Step 3: Updated list wapas save karein
    await saveWorkouts(workouts);
  }

  // 🔹 FUNCTION 4: updateWorkout() - Existing workout update karein
  //
  // KYA KARTA HAI: Workout ko ID se dhoondta hai
  // phir uski jagah updated workout rakh deta hai
  static Future<void> updateWorkout(Workout updatedWorkout) async {
    // 🔹 Step 1: Existing workouts load karein
    final workouts = await loadWorkouts();

    // 🔹 Step 2: Workout ko ID se dhoondhein
    // indexWhere - condition match karne wala index return karega
    final index = workouts.indexWhere((w) => w.id == updatedWorkout.id);

    // 🔹 Step 3: Agar mil gaya to update karein
    if (index != -1) { // -1 means nahi mila
      workouts[index] = updatedWorkout; // purani jagah naya workout
      await saveWorkouts(workouts); // wapas save karein
    }
  }

  // 🔹 FUNCTION 5: deleteWorkout() - Workout delete karein
  //
  // KYA KARTA HAI: ID ke hisaab se workout dhoond kar remove kar deta hai
  static Future<void> deleteWorkout(String id) async {
    // 🔹 Step 1: Existing workouts load karein
    final workouts = await loadWorkouts();

    // 🔹 Step 2: Remove workout with matching ID
    // removeWhere - condition true hone wale items remove karega
    workouts.removeWhere((w) => w.id == id);

    // 🔹 Step 3: Updated list save karein
    await saveWorkouts(workouts);
  }

  // ============================================================
  // SECTION 2: SETTINGS RELATED FUNCTIONS
  // ============================================================

  // 🔹 FUNCTION 6: loadUserName() - User name load karein
  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    // getString('userName') - agar nahi mila to 'User' return karo
    return prefs.getString(_userNameKey) ?? 'User';
  }

  // 🔹 FUNCTION 7: saveUserName() - User name save karein
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // 🔹 FUNCTION 8: loadDarkMode() - Dark mode setting load karein
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    // getBool('darkMode') - agar nahi mila to false (light mode) return karo
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // 🔹 FUNCTION 9: saveDarkMode() - Dark mode setting save karein
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  // ============================================================
  // SECTION 3: DEMO DATA - Pehli baar app open ho to sample data de
  // ============================================================

  // 🔹 FUNCTION 10: addDemoDataIfEmpty()
  //
  // KYA KARTA HAI: Agar koi workout nahi hai to ek demo workout create karta hai
  // Taake app khali na lage jab user pehli baar open kare
  static Future<void> addDemoDataIfEmpty() async {
    // 🔹 Step 1: Check karo agar workouts hain
    final workouts = await loadWorkouts();

    // 🔹 Step 2: Agar empty hai to demo data add karo
    if (workouts.isEmpty) {
      // Ek demo workout create karo
      final demoWorkout = Workout(
        id: 'demo_1',
        name: '💪 Chest Day',
        date: DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        // subtract - 1 din pehle ki date
        duration: 45,
        notes: 'Great workout! Felt strong 💪',
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            sets: 3,
            reps: 10,
            weight: 80,
            muscleGroup: 'Chest',
          ),
          Exercise(
            id: 'ex2',
            name: 'Incline Press',
            sets: 3,
            reps: 8,
            weight: 70,
            muscleGroup: 'Chest',
          ),
          Exercise(
            id: 'ex3',
            name: 'Cable Flyes',
            sets: 3,
            reps: 12,
            weight: 40,
            muscleGroup: 'Chest',
          ),
        ],
      );

      // Demo workout ko save karo
      await addWorkout(demoWorkout);
    }
  }
}