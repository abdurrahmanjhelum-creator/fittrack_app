import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';
import '../services/storage_service.dart';
import 'workout_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Workout> _workouts = [];
  String _userName = 'Alex';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await StorageService.addDemoDataIfEmpty();
    final workouts = await StorageService.loadWorkouts();
    final userName = await StorageService.loadUserName();
    setState(() {
      _workouts = workouts;
      _userName = userName.isEmpty ? 'Alex' : userName;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const secondaryBlue = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              '🏋️ FitTrack',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) => _loadData()),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTabContent(),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [primaryBlue, secondaryBlue]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: primaryBlue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutDetailScreen()),
                ).then((_) => _loadData()),
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Workout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.history, 'History', 1),
            _buildNavItem(Icons.bar_chart, 'Progress', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildHistory();
      case 2: return _buildProgress();
      case 3: return _buildProfile();
      default: return _buildDashboard();
    }
  }

  // --- DASHBOARD TAB ---
  Widget _buildDashboard() {
    int totalDur = _workouts.fold(0, (sum, w) => sum + w.duration);
    int totalEx = _workouts.fold(0, (sum, w) => sum + w.exercises.length);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good Morning, 👋', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  Text(_userName, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 28)),
                  Text("You've completed ${_workouts.length} workouts", style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ],
              ),
            ),
            _buildStatsCard(totalDur, totalEx),
            _buildHeader('📋 Recent Workouts', 'See All', () => setState(() => _currentIndex = 1)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(color: Color(0xFFE2E8F0))),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _workouts.length > 3 ? 3 : _workouts.length,
              itemBuilder: (context, index) => _buildWorkoutCard(_workouts[index]),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int dur, int ex) {
    const primaryBlue = Color(0xFF2563EB);
    const secondaryBlue = Color(0xFF3B82F6);
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryBlue, secondaryBlue]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.fitness_center, _workouts.length.toString(), 'Workouts'),
          _buildStatItem(Icons.timer, dur.toString(), 'Minutes'),
          _buildStatItem(Icons.repeat, ex.toString(), 'Exercises'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildHeader(String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: Color(0xFF2563EB)))),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    final date = DateFormat('MMM dd, yyyy').format(DateTime.parse(workout.date));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)),
        ).then((_) => _loadData()),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${workout.exercises.length} exercises • $date', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  if (workout.notes.isNotEmpty)
                    Text(workout.notes, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(workout.duration.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('min', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- HISTORY TAB ---
  Widget _buildHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _workouts.length,
      itemBuilder: (context, index) => _buildWorkoutCard(_workouts[index]),
    );
  }

  // --- PROGRESS TAB ---
  Widget _buildProgress() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildMetricCard('Monthly Consistency', '88%', Icons.trending_up, Colors.green),
          _buildMetricCard('Strength Gain', '+12kg', Icons.fitness_center, Colors.blue),
          _buildMetricCard('Active Minutes', '${_workouts.fold(0, (s, w) => s + w.duration)}', Icons.timer, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title),
        trailing: Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Member since 2026', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((_) => _loadData()),
            child: const Text('Edit Settings'),
          )
        ],
      ),
    );
  }
}
