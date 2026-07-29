// 📁 models/workout_model.dart
//
// YEH KYA HAI: Ye file batati hai ke humara data kis structure mein store hoga
// JAISE: Ek form mein fields hote hain, waise hi ye model hai
//
// MODEL KYA HAI: Data ka blueprint/template
// Jaise agar aapko ek student ka data store karna hai to
// student = { name: "Ali", age: 20, class: "10th" }
// Ye hi structure define karta hai model

import 'dart:convert'; // JSON encode/decode ke liye (data ko string mein badalna)

// ============================================================
// CLASS 1: Workout - Ye complete workout ka data store karega
// ============================================================
class Workout {
  // 🔹 PROPERTIES (Variables)
  final String id;          // Har workout ki unique pehchan (jaise roll number)
  final String name;        // Workout ka naam (jaise "Chest Day")
  final String date;        // Kab kiya workout (jaise "2026-07-29")
  final int duration;       // Kitne minutes lage (jaise 45)
  final String notes;       // Kuch extra notes (jaise "Good workout!")
  final List<Exercise> exercises; // Is workout mein kitne exercises hain

  // 🔹 CONSTRUCTOR - Naya object banane ka tareeqa
  // required = ye value dena zaroori hai
  // default values = agar koi value na de to ye default use hogi
  Workout({
    required this.id,        // id dena zaroori hai
    required this.name,      // name dena zaroori hai
    required this.date,      // date dena zaroori hai
    required this.duration,  // duration dena zaroori hai
    this.notes = '',         // agar notes na de to '' (empty) ho jayega
    this.exercises = const [], // agar exercises na de to empty list
  });

  // 🔹 fromJson - JSON string se model banayein
  // JSON = JavaScript Object Notation (data ka text format)
  // Jaise: {"name": "Chest Day", "duration": 45}
  // Ye function JSON ko read karke Workout object banayega
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      // ?? ka matlab: agar id nahi hai to naya id banao (current time ka number)

      name: json['name'] ?? 'Untitled Workout',
      // agar name nahi to default name de do

      date: json['date'] ?? DateTime.now().toIso8601String(),
      // agar date nahi to aaj ki date

      duration: json['duration'] ?? 0,
      // agar duration nahi to 0

      notes: json['notes'] ?? '',
      // agar notes nahi to empty string

      exercises: json['exercises'] != null
          ? (json['exercises'] as List)  // agar exercises hain to
          .map((e) => Exercise.fromJson(e)) // har exercise ko model mein convert karo
          .toList()
          : [], // nahi to empty list
    );
  }

  // 🔹 toJson - Model ko JSON string mein convert karein
  // Ye function Workout object ko map (key-value pairs) mein badal deta hai
  // Taake hum ise save kar sakein
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'duration': duration,
      'notes': notes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      // har exercise ko bhi JSON mein convert karo
    };
  }

  // 🔹 copyWith - Existing object ki copy banayein with some changes
  // Jaise agar kisi workout ka naam change karna hai to purana workout le kar
  // sirf naam change karke naya workout bana sakte hain
  Workout copyWith({
    String? id,
    String? name,
    String? date,
    int? duration,
    String? notes,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,        // agar naya id diya to use karo, nahi to purana
      name: name ?? this.name,  // agar naya naam diya to use karo
      date: date ?? this.date,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
    );
  }
}

// ============================================================
// CLASS 2: Exercise - Ek exercise ka data store karega
// ============================================================
class Exercise {
  // 🔹 PROPERTIES
  final String id;          // Har exercise ki unique pehchan
  final String name;        // Exercise ka naam (jaise "Bench Press")
  final int sets;           // Kitne sets kiye (jaise 3)
  final int reps;           // Har set mein kitne reps (jaise 10)
  final double weight;      // Kitna weight uthaya (jaise 80 kg)
  final String muscleGroup; // Kis muscle par focus (jaise "Chest")

  // 🔹 CONSTRUCTOR
  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.muscleGroup = 'Other', // default "Other" hai
  });

  // 🔹 fromJson - JSON se Exercise banayein
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Exercise',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(), // double mein convert
      muscleGroup: json['muscleGroup'] ?? 'Other',
    );
  }

  // 🔹 toJson - Exercise ko JSON mein convert karein
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'muscleGroup': muscleGroup,
    };
  }

  // 🔹 copyWith - Copy banayein with changes
  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? muscleGroup,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }
}