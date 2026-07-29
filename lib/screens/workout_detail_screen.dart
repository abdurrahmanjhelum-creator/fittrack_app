import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/storage_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout? workout;

  const WorkoutDetailScreen({super.key, this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  List<Exercise> _exercises = [];
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.workout != null;
    _nameController = TextEditingController(text: widget.workout?.name ?? '');
    _durationController = TextEditingController(text: widget.workout?.duration.toString() ?? '');
    _notesController = TextEditingController(text: widget.workout?.notes ?? '');
    _exercises = List.from(widget.workout?.exercises ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout Name is required'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final workout = Workout(
      id: widget.workout?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      date: widget.workout?.date ?? DateTime.now().toIso8601String(),
      duration: int.tryParse(_durationController.text) ?? 0,
      notes: _notesController.text,
      exercises: _exercises,
    );

    if (_isEditing) {
      await StorageService.updateWorkout(workout);
    } else {
      await StorageService.addWorkout(workout);
    }

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Workout saved! ✅')]),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  void _showExerciseDialog([Exercise? exercise, int? index]) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        exercise: exercise,
        onSave: (newExercise) {
          setState(() {
            if (index != null) {
              _exercises[index] = newExercise;
            } else {
              _exercises.add(newExercise);
            }
          });
        },
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Delete '${_nameController.text}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.deleteWorkout(widget.workout!.id);
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const secondaryBlue = Color(0xFF3B82F6);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Workout' : 'New Workout',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              onPressed: _showDeleteDialog,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Workout Name *"),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, "e.g., Chest Day", Icons.fitness_center),
                  const SizedBox(height: 16),
                  _buildLabel("Duration (minutes)"),
                  const SizedBox(height: 8),
                  _buildTextField(_durationController, "e.g., 45", Icons.timer, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildLabel("Notes"),
                  const SizedBox(height: 8),
                  _buildTextField(_notesController, "How did it go?", Icons.note, height: 80, maxLines: 3),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🏋️ Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                      TextButton(
                        onPressed: () => _showExerciseDialog(),
                        child: const Text('+ Add Exercise', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  if (_exercises.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) => _buildExerciseCard(_exercises[index], index),
                    ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [primaryBlue, secondaryBlue]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isEditing ? 'UPDATE WORKOUT' : 'SAVE WORKOUT',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text, double height = 56, int maxLines = 1}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: const Column(
        children: [
          Icon(Icons.fitness_center, color: Color(0xFF64748B), size: 48),
          SizedBox(height: 8),
          Text("No exercises added yet", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2563EB),
            child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text("${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight}kg",
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit, size: 20, color: Color(0xFF64748B)), onPressed: () => _showExerciseDialog(exercise, index)),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Color(0xFFEF4444)),
            onPressed: () => setState(() => _exercises.removeAt(index)),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;

  const _ExerciseDialog({this.exercise, required this.onSave});

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  String _muscleGroup = 'Chest';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _setsController = TextEditingController(text: widget.exercise?.sets.toString() ?? '3');
    _repsController = TextEditingController(text: widget.exercise?.reps.toString() ?? '10');
    _weightController = TextEditingController(text: widget.exercise?.weight.toString() ?? '0');
    _muscleGroup = widget.exercise?.muscleGroup ?? 'Chest';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Exercise Name *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _setsController, decoration: const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _muscleGroup,
                    decoration: const InputDecoration(labelText: 'Muscle', border: OutlineInputBorder()),
                    items: ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _muscleGroup = val!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) return;
            widget.onSave(Exercise(
              id: widget.exercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              sets: int.tryParse(_setsController.text) ?? 3,
              reps: int.tryParse(_repsController.text) ?? 10,
              weight: double.tryParse(_weightController.text) ?? 0.0,
              muscleGroup: _muscleGroup,
            ));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
